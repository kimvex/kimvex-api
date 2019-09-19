class Shop
  def self.setPathApi(url : String)
    post "#{url}/shop" do |env|
      begin
        if env.params.json.has_key?("shop_name") && env.params.json.has_key?("address")
          user_id = Authentication.current_session(env.request.headers["token"])
          shop_name = env.params.json["shop_name"]
          address = env.params.json["address"]
          phone = env.params.json.has_key?("phone") ? "#{env.params.json["phone"].not_nil!}" : nil
          phone2 = env.params.json.has_key?("phone2") ? "#{env.params.json["phone2"].not_nil!}" : nil
          description = validateField("description", env)
          cover_image = validateField("cover_image", env)
          logo = validateField("logo", env)
          accept_card = validateField("accept_card", env)
          list_cards = validateField("list_cards", env)
          shop_schedules = env.params.json.has_key?("shop_schedules") ? env.params.json["shop_schedules"].not_nil!.as(Array) : nil
          lat = validateField("lat", env)
          lon = validateField("lon", env)
          service_type_id = env.params.json.has_key?("service_type_id") ? "#{env.params.json["service_type_id"]}".to_i : nil
          sub_service_type_id = env.params.json.has_key?("sub_service_type_id") ? "#{env.params.json["sub_service_type_id"]}".to_i : nil

          shop = [] of DB::Any

          shop << shop_name.to_s
          shop << address.to_s
          shop << phone
          shop << phone2
          shop << description
          shop << cover_image
          shop << accept_card
          shop << list_cards
          shop << lat
          shop << lon
          shop << false
          shop << user_id
          shop << logo
          shop << service_type_id
          shop << sub_service_type_id

          shop_id_insert = DB_K
            .table(:shop)
            .insert([:shop_name, :address, :phone, :phone2, :description, :cover_image, :accept_card, :list_cards, :lat, :lon, :score_shop, :user_id, :logo, :service_type_id, :sub_service_type_id], shop)
            .execute

          DB_K
            .table(:pages)
            .insert([:shop_id], [shop_id_insert])
            .execute

          services = DB_K
            .select([
            :sub_service_name,
          ])
            .table(:sub_service_type)
            .join(:LEFT, :service_type, [:service_name], [:service_type_id, :service_type_id])
            .where(:sub_service_type_id, sub_service_type_id)
            .and(:service_type_id, service_type_id)
            .execute_query

          MONGO.insert("shop", {
            "name"     => shop_name.to_s,
            "shop_id"  => shop_id_insert.to_s,
            "location" => {
              "type"        => "Point",
              "coordinates" => ["#{env.params.json["lon"]}".to_f, "#{env.params.json["lat"]}".to_f],
            },
            "category"     => services.not_nil![0]["service_name"].to_s,
            "sub_category" => services.not_nil![0]["sub_service_name"].to_s,
            "status"       => false,
          })

          if env.params.json.has_key?("list_images")
            list_images_array = Array(String).from_json("#{env.params.json["list_images"]}")

            list_images_array.each { |url|
              DB_K
                .table(:images_shop)
                .insert([:url_image, :shop_id], [url, shop_id_insert.to_s])
                .execute
            }
          end

          DB_K
            .table(:shop_schedules)
            .insert([:LUN, :MAR, :MIE, :JUE, :VIE, :SAB, :DOM, :shop_id], [shop_schedules.not_nil![0].to_s, shop_schedules.not_nil![1].to_s, shop_schedules.not_nil![2].to_s, shop_schedules.not_nil![3].to_s, shop_schedules.not_nil![4].to_s, shop_schedules.not_nil![5].to_s, shop_schedules.not_nil![6].to_s, shop_id_insert.to_s])
            .execute

          env.response.status_code = 200
          {message: "Create shop success", shop_id: shop_id_insert, status: 200}.to_json
        else
          raise Exception.new("Name of shop or address can't empty")
        end
      rescue exception
        error = "#{exception}"
        case error
        when "Name of shop or address can't empty"
          env.response.status_code = 400
          {message: error}.to_json
        else
          LOGGER.warn("#{error}")
          env.response.status_code = 500
          {message: "Error al agregar tienda"}.to_json
        end
      end
    end

    get "#{url}/shop/:shop_id" do |env|
      shop_id = env.params.url["shop_id"]

      begin
        shop_result = DB_K
          .select([
          :shop_id,
          :shop_name,
          :address,
          :phone,
          :phone2,
          :description,
          :cover_image,
          :accept_card,
          :list_cards,
          :lat,
          :lon,
          :score_shop,
          :status,
          :logo,
          :service_type_id,
          :sub_service_type_id,
        ])
          .table(:shop)
          .join(:LEFT, :images_shop, [:url_image], [:shop_id, :shop_id])
          .join(:LEFT, :shop_schedules, [:LUN, :MAR, :MIE, :JUE, :VIE, :SAB, :DOM], [:shop_id, :shop_id])
          .join(:LEFT, :usersk, [:user_id], [:user_id, :user_id])
          .where(:shop_id, shop_id)
          .group_concat([:url_image, :images_shop, :url], :image_id, :images)
          .first

        shop_result.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500
        {message: "Error al obtener tienda"}.to_json
      end
    end

    put "#{url}/shop/:shop_id/update" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url["shop_id"]
      shop_name = env.params.json.has_key?("shop_name") ? env.params.json["shop_name"] : nil
      address = env.params.json.has_key?("address") ? env.params.json["address"] : nil
      phone = env.params.json.has_key?("phone") ? "#{env.params.json["phone"].not_nil!}" : nil
      phone2 = env.params.json.has_key?("phone2") ? "#{env.params.json["phone2"].not_nil!}" : nil
      description = env.params.json.has_key?("description") ? env.params.json["description"] : nil
      cover_image = env.params.json.has_key?("cover_image") ? env.params.json["cover_image"] : nil
      logo = env.params.json.has_key?("logo") ? env.params.json["logo"] : nil
      accept_card = validateField("accept_card", env)
      shop_schedules = env.params.json.has_key?("shop_schedules") ? env.params.json["shop_schedules"].not_nil!.as(Array) : nil
      list_cards = env.params.json.has_key?("list_cards") ? env.params.json["list_cards"] : nil
      service_type = env.params.json.has_key?("service_type") ? env.params.json["service_type"] : nil
      lat = env.params.json.has_key?("lat") ? env.params.json["lat"] : nil
      lon = env.params.json.has_key?("lon") ? env.params.json["lon"] : nil
      service_type_id = env.params.json.has_key?("service_type_id") ? "#{env.params.json["service_type_id"]}".to_i : nil
      sub_service_type_id = env.params.json.has_key?("sub_service_type_id") ? "#{env.params.json["sub_service_type_id"]}".to_i : nil

      field_shop_update = [] of String
      data_shop_update = [] of String | Int32 | Float64
      mongo_update = {} of String => Hash(String, String | Array(Float64)) | String

      begin
        if shop_name
          field_shop_update << "shop_name"
          data_shop_update << shop_name.to_s
          mongo_update["name"] = shop_name.to_s
        end

        if address
          field_shop_update << "address"
          data_shop_update << address.to_s
        end

        if phone
          field_shop_update << "phone"
          data_shop_update << phone
        end

        if phone2
          field_shop_update << "phone2"
          data_shop_update << phone2
        end

        if description
          field_shop_update << "description"
          data_shop_update << description.to_s
        end

        if cover_image
          field_shop_update << "cover_image"
          data_shop_update << cover_image.to_s
        end

        if accept_card
          field_shop_update << "accept_card"
          data_shop_update << accept_card.to_s
        end

        if list_cards
          field_shop_update << "list_cards"
          data_shop_update << list_cards.to_s
        end

        if service_type_id && sub_service_type_id
          services = DB_K
            .select([
            :sub_service_name,
          ])
            .table(:sub_service_type)
            .join(:LEFT, :service_type, [:service_name], [:service_type_id, :service_type_id])
            .where(:sub_service_type_id, sub_service_type_id)
            .and(:service_type_id, service_type_id)
            .execute_query

          field_shop_update << "service_type_id"
          data_shop_update << service_type_id

          field_shop_update << "sub_service_type_id"
          data_shop_update << sub_service_type_id

          mongo_update["category"] = services.not_nil![0]["service_name"].to_s
          mongo_update["sub_category"] = services.not_nil![0]["sub_service_name"].to_s
        end

        if lat && lon
          field_shop_update << "lat"
          data_shop_update << "#{lat}".to_f
          field_shop_update << "lon"
          data_shop_update << "#{lon}".to_f
          mongo_update["location"] = {
            "type"        => "Point",
            "coordinates" => ["#{lon}".to_f, "#{lat}".to_f],
          }
        end

        if logo
          field_shop_update << "logo"
          data_shop_update << "#{logo}".to_s
        end

        DB_K
          .table(:shop)
          .update(field_shop_update, data_shop_update)
          .where(:user_id, user_id)
          .and(:shop_id, shop_id)
          .execute

        MONGO.update("shop", {"shop_id" => shop_id}, {"$set" => mongo_update})

        if env.params.json.has_key?("list_images")
          list_images_array = Array(String).from_json("#{env.params.json["list_images"]}")

          list_images_array.each { |url|
            puts shop_id
            puts url
            DB_K
              .table(:images_shop)
              .insert([:url_image, :shop_id], [url, shop_id])
              .execute
          }
        end
        DB_K
          .table(:shop_schedules)
          .update([:LUN, :MAR, :MIE, :JUE, :VIE, :SAB, :DOM], [shop_schedules.not_nil![0].to_s, shop_schedules.not_nil![1].to_s, shop_schedules.not_nil![2].to_s, shop_schedules.not_nil![3].to_s, shop_schedules.not_nil![4].to_s, shop_schedules.not_nil![5].to_s, shop_schedules.not_nil![6].to_s])
          .where(
          :shop_id, shop_id
        )
          .execute

        env.response.status_code = 200
        {message: "Success update", status_code: 200}.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 400
        {message: "Error params request"}.to_json
      end
    end

    get "#{url}/profile/shops" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])

      begin
        shop_result = DB_K
          .select([
          :shop_id,
          :shop_name,
          :address,
          :phone,
          :phone2,
          :description,
          :cover_image,
          :accept_card,
          :list_cards,
          :lat,
          :lon,
          :score_shop,
          :status,
        ])
          .table(:shop)
          .join(:LEFT, :images_shop, [:url_image], [:shop_id, :shop_id])
          .join(:LEFT, :service_type, [:service_name], [:service_type_id, :service_type_id])
          .join(:LEFT, :sub_service_type, [:sub_service_name], [:sub_service_type_id, :sub_service_type_id])
          .join(:LEFT, :shop_schedules, [:LUN, :MAR, :MIE, :JUE, :VIE, :SAB, :DOM], [:shop_id, :shop_id])
          .join(:LEFT, :plans_pay, [:date_init, :date_finish], [:shop_id, :shop_id])
          .join(:LEFT, :usersk, [:user_id], [:user_id, :user_id])
          .where(:user_id, user_id.to_i)
          .group_concat([:url_image, :images_shop, :url], :image_id, :images)
          .execute_query

        {result: shop_result}.to_json
      rescue exception
        LOGGER.warn("#{exception}")
        env.response.status_code = 500
        {message: "Error al obtener las propiedades"}.to_json
      end
    end

    post "#{url}/shops/:shop_id/update/images" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url["shop_id"]

      begin
        response_result = ""
        HTTP::FormData.parse(env.request) do |upload|
          result_cover = CLOUDINARY.upload(upload, "shop_images")
          response_result = JSON.parse(result_cover)
        end

        DB_K
          .table(:images_shop)
          .insert([:url_image, :shop_id], [response_result["url"].to_s, shop_id.to_s])
          .execute

        {image: response_result["url"], message: "success"}.to_json
      rescue exception
        LOGGER.warn("#{exception}")
        env.response.status_code = 500
        {message: "Error al agregar nueva imagen"}.to_json
      end
    end

    delete "#{url}/shops/:shop_id/image" do |env|
      shop_id = env.params.url["shop_id"]
      url_image = env.params.json.has_key?("url_image") ? env.params.json["url_image"] : nil

      begin
        DB_K
          .delete
          .table(:images_shop)
          .where(:url_image, url_image.to_s)
          .and(:shop_id, shop_id)
          .execute

        {message: "Imagen eliminada"}.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500
        {message: "Error al eliminar la imagen"}.to_json
      end
    end

    post "#{url}/shop/:shop_id/comment" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url["shop_id"]
      comment = env.params.json.has_key?("comment") ? env.params.json["comment"].to_s : ""

      begin
        result = DB_K
          .table(:shop_comments)
          .insert([:user_id, :shop_id, :comment], [user_id, shop_id, comment])
          .execute

        {comment_id: result}.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500
        {message: "Error al insertar comentario"}.to_json
      end
    end

    get "#{url}/shop/:shop_id/comments" do |env|
      shop_id = env.params.url["shop_id"]

      begin
        comments = DB_K
          .select([
          :comment,
          :create_date_at,
        ])
          .table(:shop_comments)
          .join(:LEFT, :usersk, [:user_id, :fullname, :image], [:user_id, :user_id])
          .where(:shop_id, shop_id.to_i)
          .order_by([:create_date_at])
          .order_direction
          .execute_query

        comments.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        {message: "Error al obtener los comentarios"}.to_json
      end
    end

    post "#{url}/shop/:shop_id/score" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url["shop_id"]
      score = env.params.json.has_key?("score") ? "#{env.params.json["score"]}".to_i : 1

      begin
        id_score = DB_K
          .table(:shop_score_users)
          .insert([:user_id, :shop_id, :score], [user_id, shop_id, score])
          .execute

        score_shop = DB_K
          .select([
          :score,
        ])
          .table(:shop_score_users)
          .where(:shop_id, shop_id.to_i)
          .avg(:score, :score_shop, :shop_id)
          .execute_query
        puts score_shop
        DB_K
          .table(:shop)
          .update([:score_shop], ["#{score_shop.not_nil![0]["score_shop"]}".to_f.round(1)])
          .where(:shop_id, shop_id)
          .execute

        {score: "#{score_shop.not_nil![0]["score_shop"]}".to_f.round(1)}.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500
        {message: "Error al calificar"}.to_json
      end
    end

    get "#{url}/shop/:shop_id/score" do |env|
      shop_id = env.params.url["shop_id"]

      begin
        score_shop = DB_K
          .select([
          :score,
        ])
          .table(:shop_score_users)
          .where(:shop_id, shop_id.to_i)
          .avg(:score, :score_shop, :shop_id)
          .execute_query

        {score: "#{score_shop.not_nil!.first["score_shop"]}".to_f.round(1)}.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500
        {message: "Error al obtener calificacion"}.to_json
      end
    end

    get "#{url}/shop/:shop_id/score/:user_id" do |env|
      shop_id = env.params.url["shop_id"]
      user_id = env.params.url["user_id"]

      begin
        score_shop = DB_K
          .select([
          :score,
        ])
          .table(:shop_score_users)
          .where(:shop_id, shop_id.to_i)
          .and(:user_id, user_id.to_i)
          .first

        score_shop.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500

        {message: "Error al obtener la calificacion dada por el usuario"}.to_json
      end
    end

    put "#{url}/shop/:shop_id/score/:user_id" do |env|
      shop_id = env.params.url["shop_id"]
      user_id = env.params.url["user_id"]
      score = env.params.json.has_key?("score") ? "#{env.params.json["score"]}".to_i : nil

      begin
        if score.not_nil!
          DB_K
            .table(:shop_score_users)
            .update(["score"], [score])
            .where(:user_id, user_id.to_i)
            .and(:shop_id, shop_id.to_i)
            .execute

          score_shop = DB_K
            .select([
            :score,
          ])
            .table(:shop_score_users)
            .where(:shop_id, shop_id.to_i)
            .avg(:score, :score_shop, :shop_id)
            .execute_query

          DB_K
            .table(:shop)
            .update([:score_shop], ["#{score_shop.not_nil![0]["score_shop"]}".to_f.round(1)])
            .where(:shop_id, shop_id)
            .execute

          {message: "Calificacion actualizada"}.to_json
        else
          raise Exception.new("Score can't be empty")
        end
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 500

        {message: "Error al actualizar la calificación"}.to_json
      end
    end

    get "#{url}/list/shops/:lat/:lon" do |env|
      limit = env.params.query.has_key?("limit") ? env.params.query["limit"].to_i : 10
      last_shop = env.params.query.has_key?("last_shop_id") ? env.params.query["last_shop_id"] : 0
      minDistance = env.params.query.has_key?("minDistance") ? env.params.query["minDistance"].to_f : 0.0

      begin
        get_shops = MONGO.aggregate([
          {
            "$geoNear" => {
              "near" => {
                "type"        => "Point",
                "coordinates" => ["#{env.params.url["lon"]}".to_f, "#{env.params.url["lat"]}".to_f],
              },
              "minDistance"   => minDistance,
              "spherical"     => true,
              "distanceField" => "distance",
            },
          },
          {
            "$match" => {
              "status"  => true,
              "shop_id" => {"$nin" => [last_shop]},
            },
          },
          {
            "$limit" => limit,
          },
        ], "shop")

        result_properties = [] of JSON::Any
        values_arr = [] of Int32

        if get_shops.empty?
          env.response.status_code = 200
          next get_shops.to_json
        end

        get_shops.map { |value|
          values_arr << "#{value["shop_id"]}".to_i
        }

        shops = DB_K
          .select([
          :shop_id,
          :shop_name,
          :address,
          :phone,
          :score_shop,
          :cover_image,
        ])
          .table(:shop)
          .join(:LEFT, :service_type, [:service_name], [:service_type_id, :service_type_id])
          .join(:LEFT, :sub_service_type, [:sub_service_name], [:sub_service_type_id, :sub_service_type_id])
          .where_in(:shop_id, values_arr)
          .execute_query

        order_shops = get_shops.not_nil!.map { |shop_data|
          hash_match = shops.not_nil!.find { |hash_r|
            "#{shop_data["shop_id"]}".to_i == hash_r["shop_id"]
          }

          hash_match.not_nil!["distance"] = shop_data["distance"]
          hash_match
        }

        {
          shops:         order_shops,
          last_shop_id:  order_shops.last.not_nil!["shop_id"],
          last_distance: order_shops.last.not_nil!["distance"],
        }.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 400
        {message: "Error params request"}.to_json
      end
    end

    get "#{url}/find/shops/:lat/:lon" do |env|
      limit = env.params.query.has_key?("limit") ? env.params.query["limit"].to_i : 10
      last_shop = env.params.query.has_key?("last_shop_id") ? env.params.query["last_shop_id"] : 0
      minDistance = env.params.query.has_key?("minDistance") ? env.params.query["minDistance"].to_f : 0.0
      category = env.params.query["category"].to_s

      begin
        get_shops = MONGO.aggregate([
          {
            "$geoNear" => {
              "near" => {
                "type"        => "Point",
                "coordinates" => ["#{env.params.url["lon"]}".to_f, "#{env.params.url["lat"]}".to_f],
              },
              "minDistance"   => minDistance,
              "spherical"     => true,
              "distanceField" => "distance",
            },
          },
          {
            "$match" => {
              "status"   => true,
              "category" => category,
              "shop_id"  => {"$nin" => [last_shop]},
            },
          },
          {
            "$limit" => limit,
          },
        ], "shop")

        result_properties = [] of JSON::Any
        values_arr = [] of Int32

        if get_shops.empty?
          env.response.status_code = 200
          next get_shops.to_json
        end

        get_shops.map { |value| values_arr << "#{value["shop_id"]}".to_i }

        shops = DB_K
          .select([
          :shop_id,
          :shop_name,
          :address,
          :phone,
          :score_shop,
          :cover_image,
        ])
          .table(:shop)
          .join(:LEFT, :service_type, [:service_name], [:service_type_id, :service_type_id])
          .join(:LEFT, :sub_service_type, [:sub_service_name], [:sub_service_type_id, :sub_service_type_id])
          .where_in(:shop_id, values_arr)
          .execute_query

        order_shops = get_shops.not_nil!.map { |shop_data|
          hash_match = shops.not_nil!.find { |hash_r|
            "#{shop_data["shop_id"]}".to_i == hash_r["shop_id"]
          }

          puts shop_data
          puts hash_match

          hash_match.not_nil!["distance"] = shop_data["distance"]
          hash_match
        }

        {
          shop:          order_shops,
          last_shop_id:  order_shops.last.not_nil!["shop_id"],
          last_distance: order_shops.last.not_nil!["distance"],
        }.to_json
      rescue exception
        LOGGER.warn("#{exception}")

        env.response.status_code = 400
        {message: "Error params request"}.to_json
      end
    end

    put "#{url}/shop/lock/:shop_id" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url["shop_id"]

      mongo_update_shop = {} of String => Bool
      mongo_update_offers = {} of String => Bool

      begin
        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, 1)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        mongo_update_shop["status"] = false
        mongo_update_offers["active"] = false

        DB_K
          .table(:shop)
          .update(["status"], [0])
          .where(:user_id, user_id)
          .and(:shop_id, shop_id)
          .execute

        DB_K
          .table(:offers)
          .update(["active"], [0])
          .where(:shop_id, shop_id)
          .and(:user_id, user_id)
          .execute

        DB_K
          .table(:pages)
          .update(["active"], [0])
          .where(:shop_id, shop_id)
          .execute

        MONGO.update("shop", {"shop_id" => shop_id}, {"$set" => mongo_update_shop})
        MONGO.update_many("offers", {"shop_id" => shop_id.to_s}, {"$set" => mongo_update_offers})

        {message: "Tienda desabilitada"}.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al desabilitar una tienda")

        env.response.status_code = 500
        {message: "Error al desactivar tienda"}.to_json
      end
    end

    post "#{url}/shop/offers" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.json.has_key?("shop_id") ? (env.params.json["shop_id"].to_s).to_i : nil
      title = env.params.json.has_key?("title") ? env.params.json["title"].to_s : nil
      description = env.params.json.has_key?("description") ? env.params.json["description"].to_s : nil
      date_init = env.params.json.has_key?("date_init") ? env.params.json["date_init"].to_s : nil
      date_end = env.params.json.has_key?("date_end") ? env.params.json["date_end"].to_s : nil
      image_url = env.params.json.has_key?("image_url") ? env.params.json["image_url"].to_s : nil

      begin
        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, true)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        position = DB_K
          .select([
          :lat,
          :lon,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .first

        offer_id_insert = DB_K
          .table(:offers)
          .insert([
          :user_id,
          :shop_id,
          :title,
          :description,
          :date_init,
          :date_end,
          :image_url,
          :lat,
          :lon,
        ],
          [
            user_id,
            shop_id,
            title,
            description,
            date_init,
            date_end,
            image_url,
            position["lat"].not_nil!.to_s,
            position["lon"].not_nil!.to_s,
          ])
          .execute

        MONGO.insert("offers", {
          "offer_id" => offer_id_insert.to_s,
          "shop_id"  => shop_id.to_s,
          "title"    => title,
          "location" => {
            "type"        => "Point",
            "coordinates" => ["#{position["lon"]}".to_f, "#{position["lat"]}".to_f],
          },
          "date_init" => date_init,
          "date_end"  => date_end,
          "active"    => true,
        })

        env.response.status_code = 200
        {message: "Created offers", offer_id: offer_id_insert, status: 200}.to_json
      rescue exception
        LOGGER.warn("#{exception} exception to create offer")

        env.response.status_code = 500
        {message: "Error when creating the offer"}.to_json
      end
    end

    get "#{url}/shops/offers/:lat/:lon" do |env|
      limit = env.params.query.has_key?("limit") ? env.params.query["limit"].to_i : 10
      last_offer = env.params.query.has_key?("last_offer_id") ? env.params.query["last_offer_id"] : 0
      minDistance = env.params.query.has_key?("minDistance") ? env.params.query["minDistance"].to_f : 0.0

      begin
        time = Time.now Time::Location.load("America/Mexico_City")
        time_paser = "#{time}".split(" ").first

        get_offers = MONGO.aggregate([
          {
            "$geoNear" => {
              "near" => {
                "type"        => "Point",
                "coordinates" => ["#{env.params.url["lon"]}".to_f, "#{env.params.url["lat"]}".to_f],
              },
              "minDistance"   => minDistance,
              "spherical"     => true,
              "distanceField" => "distance",
            },
          },
          {
            "$match" => {
              "active"   => true,
              "offer_id" => {"$nin" => [last_offer]},
              "date_end" => {"$gt" => time_paser},
            },
          },
          {
            "$limit" => limit,
          },
        ], "offers")

        values_arr = [] of Int32

        if get_offers.empty?
          env.response.status_code = 200
          next get_offers.to_json
        end

        get_offers.map { |value|
          values_arr << "#{value["offer_id"]}".to_i
        }

        puts "#{get_offers}"

        offers = DB_K
          .select([
          :title,
          :description,
          :date_init,
          :date_end,
          :image_url,
        ])
          .table(:offers)
          .join(:LEFT, :shop, [:shop_id, :shop_name, :cover_image], [:shop_id, :shop_id])
          .where_in(:offers_id, values_arr)
          .execute_query

        order_offers = get_offers.not_nil!.map { |offers_data|
          hash_match = offers.not_nil!.find { |hash_r|
            "#{offers_data["shop_id"]}".to_i == hash_r["shop_id"]
          }

          offers.not_nil!.delete(hash_match)
          hash_match.not_nil!["distance"] = offers_data["distance"]
          hash_match
        }

        env.response.status_code = 200
        {
          offers:        order_offers,
          last_offer_id: order_offers.last.not_nil!["shop_id"],
          last_distance: order_offers.last.not_nil!["distance"],
        }.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al obtener las ofertas")

        {message: "Error al obtener las ofertas", status: 500}.to_json
      end
    end

    put "#{url}/shop/offers/:offer_id" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      offer_id = env.params.url.has_key?("offer_id") ? env.params.url["offer_id"] : nil
      shop_id = env.params.json.has_key?("shop_id") ? (env.params.json["shop_id"].to_s).to_i : nil
      title = env.params.json.has_key?("title") ? env.params.json["title"].to_s : nil
      description = env.params.json.has_key?("description") ? env.params.json["description"].to_s : nil
      date_end = env.params.json.has_key?("date_end") ? env.params.json["date_end"].to_s : nil
      date_init = env.params.json.has_key?("date_init") ? env.params.json["date_init"].to_s : nil
      image_url = env.params.json.has_key?("image_url") ? env.params.json["image_url"].to_s : nil
      active = env.params.json.has_key?("active") ? (env.params.json["active"].to_s).to_i : nil

      begin
        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, 1)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        position = DB_K
          .select([
          :lat,
          :lon,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .first

        arr_fields = [] of String
        arr_values = [] of String | Int32 | Float64 | Bool
        mongo_update = {} of String => Hash(String, String | Array(Float64)) | String | Bool

        if title
          arr_fields << "title"
          arr_values << title

          mongo_update["title"] = title
        end

        if description
          arr_fields << "description"
          arr_values << description
        end

        if date_end
          arr_fields << "date_end"
          arr_values << date_end

          mongo_update["date_end"] = date_end
        end

        if date_init
          arr_fields << "date_init"
          arr_values << date_init

          mongo_update["date_init"] = date_init
        end

        if image_url
          arr_fields << "image_url"
          arr_values << image_url
        end

        if active
          active_value = active === 1 ? true : false
          arr_fields << "active"
          arr_values << active_value

          mongo_update["active"] = active < 1 ? false : true
        end

        if position["lat"] && position["lon"]
          arr_fields << "lat"
          arr_values << "#{position["lat"].not_nil!}".to_f
          arr_fields << "lon"
          arr_values << "#{position["lon"].not_nil!}".to_f

          mongo_update["location"] = {
            "type"        => "Point",
            "coordinates" => ["#{position["lon"].not_nil!.to_s}".to_f, "#{position["lat"].not_nil!.to_s}".to_f],
          }
        end

        DB_K
          .table(:offers)
          .update(arr_fields, arr_values)
          .where(:offers_id, offer_id)
          .and(:user_id, user_id)
          .and(:shop_id, shop_id)
          .execute

        MONGO.update("offers", {"offer_id" => offer_id.to_s}, {"$set" => mongo_update})

        env.response.status_code = 200
        {message: "Success update", status_code: 200}.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al actualizar oferta")

        {message: "Error al actualizar oferta", status: 500}.to_json
      end
    end

    get "#{url}/shop/:shop_id/offers" do |env|
      shop_id = env.params.url["shop_id"]
      status = env.params.query.has_key?("status") ? env.params.query["status"] : nil
      limit = env.params.query.has_key?("limit") ? env.params.query["limit"] : 10
      last_id = env.params.query.has_key?("last_id") ? env.params.query["last_id"] : 0

      begin
        if shop_id.nil?
          raise Exception.new("Params shop_id not found")
        end

        offers = DB_K
          .select([
          :offers_id,
          :title,
          :description,
          :date_init,
          :date_end,
          :image_url,
          :active,
          :lat,
          :lon,
        ])
          .table(:offers)
          .where(:shop_id, shop_id.to_i)

        case status
        when "actives"
          offers.and(:active, 1)
        when "inactive"
          offers.and(:active, 0)
        end

        offers = offers
          .and(:offers_id, last_id.to_i, ">=")
          .limit(limit)
          .execute_query

        last_id_result = 0

        if !offers.not_nil!.empty?
          last_id_result = offers.not_nil!.last["offers_id"]
        end

        env.response.status_code = 200
        {
          offers:  offers,
          last_id: last_id_result,
        }.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al obtener las ofertas de una tienda")

        env.response.status_code = 500

        {message: "Error al obtener las ofertas de una tienda"}.to_json
      end
    end

    get "#{url}/shop/offer/:offer_id" do |env|
      offer_id = env.params.url.has_key?("offer_id") ? env.params.url["offer_id"] : nil

      begin
        if offer_id.nil?
          raise Exception.new("Params offer_id not found")
        end

        offer = DB_K
          .select([
          :offers_id,
          :title,
          :description,
          :date_end,
          :image_url,
          :active,
          :lat,
          :lon,
        ])
          .table(:offers)
          .join(:LEFT, :shop, [:shop_id, :shop_name, :cover_image], [:shop_id, :shop_id])
          .where(:offers_id, offer_id.to_i)
          .execute_query

        env.response.status_code = 200
        {offer: offer}.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al obtener la oferta")

        env.response.status_code = 500

        {message: "Error al obtener la oferta"}.to_json
      end
    end

    put "#{url}/shop/:shop_id/offer/:offer_id/disabled" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      offer_id = env.params.url.has_key?("offer_id") ? env.params.url["offer_id"] : nil
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil

      begin
        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        DB_K
          .table(:offers)
          .update([:active], [false])
          .where(:offers_id, offer_id)
          .and(:user_id, user_id)
          .and(:shop_id, shop_id)
          .execute

        MONGO.update("offers", {"offer_id" => offer_id.to_s}, {"$set" => {
                                                                 "active" => false,
                                                               }})

        env.response.status_code = 200
        {message: "Success update", status_code: 200}.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al desactivar la oferta")

        env.response.status_code = 500

        {message: "Error al desactivar la oferta"}.to_json
      end
    end

    get "#{url}/services" do |env|
      begin
        services = DB_K
          .select([
          :service_type_id,
          :service_name,
        ])
          .table(:service_type)
          .execute_query

        {services: services.not_nil!}.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al obtener los servicios")

        env.response.status_code = 500
        {message: "Error al obtener los servicios"}
      end
    end

    get "#{url}/shop/:shop_id/page" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil

      begin
        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, 1)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        page = DB_K
          .select([
          :active,
          :template_type,
          :style_sheets,
          :active_days,
          :images_days,
          :offers_active,
          :accept_card_active,
          :subdomain,
          :domain,
          :shop_id,
          :pages_id,
        ])
          .table(:pages)
          .join(:LEFT, :shop, [:shop_name, :description, :cover_image, :logo], [:shop_id, :shop_id])
          .where(:shop_id, shop_id)
          .first
        {page: page}.to_json
      rescue exception
        LOGGER.warn("#{exception} No se pudo obtener la informacion de la pagina")

        env.response.status_code = 403
        {message: "No se pudo obtener la informacion de la pagina"}
      end
    end

    put "#{url}/shop/:shop_id/update_page/:page_id" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil
      page_id = env.params.url.has_key?("page_id") ? env.params.url["page_id"] : nil
      template_type = env.params.json.has_key?("template_type") ? (env.params.json["template_type"].to_s).to_i : nil
      style_sheets = env.params.json.has_key?("style_sheets") ? (env.params.json["style_sheets"].to_s).to_i : nil
      active_days = env.params.json.has_key?("active_days") ? (env.params.json["active_days"].to_s).to_i : nil
      images_days = env.params.json.has_key?("images_days") ? (env.params.json["images_days"].to_s).to_i : nil
      offers_active = env.params.json.has_key?("offers_active") ? (env.params.json["offers_active"].to_s).to_i : nil
      accept_card_active = env.params.json.has_key?("accept_card_active") ? (env.params.json["accept_card_active"].to_s).to_i : nil
      subdomain = env.params.json.has_key?("subdomain") ? env.params.json["subdomain"].to_s : nil
      domain = env.params.json.has_key?("domain") ? env.params.json["domain"].to_s : nil

      begin
        arr_fields = [] of String
        arr_values = [] of String | Int32 | Float64 | Bool

        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, 1)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        if template_type
          arr_fields << "template_type"
          arr_values << template_type
        end

        if style_sheets
          arr_fields << "style_sheets"
          arr_values << style_sheets
        end

        if active_days
          arr_fields << "active_days"
          arr_values << active_days
        end

        if images_days
          arr_fields << "images_days"
          arr_values << images_days
        end

        if offers_active
          arr_fields << "offers_active"
          arr_values << offers_active
        end

        if accept_card_active
          arr_fields << "accept_card_active"
          arr_values << accept_card_active
        end

        if subdomain
          exist_subdomain = DB_K
            .select([
            :subdomain,
            :shop_id,
          ])
            .table(:pages)
            .where(:subdomain, subdomain)
            .first

          if exist_subdomain.empty?
            arr_fields << "subdomain"
            arr_values << subdomain
          elsif exist_subdomain["shop_id"] === shop_id
            arr_fields << "subdomain"
            arr_values << subdomain
          end
        end

        if domain
          exist_domain = DB_K
            .select([
            :subdomain,
            :shop_id,
          ])
            .table(:pages)
            .where(:subdomain, subdomain)
            .first

          if exist_domain.empty?
            arr_fields << "domain"
            arr_values << domain
          elsif exist_domain["shop_id"] === shop_id
            arr_fields << "domain"
            arr_values << domain
          end
        end

        DB_K
          .table(:pages)
          .update(arr_fields, arr_values)
          .where(:pages_id, page_id)
          .execute

        {success: "Actualizado"}.to_json
      rescue exception
        LOGGER.warn("#{exception} No se pudo actualizar la informacion de la pagina")

        env.response.status_code = 403
        {message: "No se pudo actualizar la informacion de la pagina"}
      end
    end

    put "#{url}/shop/:shop_id/active_page/:page_id" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil
      page_id = env.params.url.has_key?("page_id") ? env.params.url["page_id"] : nil

      begin
        arr_fields = [] of String
        arr_values = [] of String | Int32 | Float64 | Bool

        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, 1)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        DB_K
          .table(:pages)
          .update([:active], [true])
          .where(:pages_id, page_id)
          .execute

        {success: "Actualizado"}.to_json
      rescue exception
        LOGGER.warn("#{exception} No se pudo actualizar la informacion de la pagina")

        env.response.status_code = 403
        {message: "No se pudo actualizar la informacion de la pagina"}
      end
    end

    put "#{url}/shop/:shop_id/deactivate_page/:page_id" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil
      page_id = env.params.url.has_key?("page_id") ? env.params.url["page_id"] : nil

      begin
        arr_fields = [] of String
        arr_values = [] of String | Int32 | Float64 | Bool

        is_owner = DB_K
          .select([
          :shop_id,
        ])
          .table(:shop)
          .where(:user_id, user_id.to_i)
          .and(:shop_id, shop_id)
          .and(:status, 1)
          .execute_query

        if is_owner.not_nil!.size < 1
          raise Exception.new("Not is owner or active shop")
        end

        DB_K
          .table(:pages)
          .update([:active], [false])
          .where(:pages_id, page_id)
          .execute

        {success: "Actualizado"}.to_json
      rescue exception
        LOGGER.warn("#{exception} No se pudo actualizar la informacion de la pagina")

        env.response.status_code = 403
        {message: "No se pudo actualizar la informacion de la pagina"}
      end
    end

    get "#{url}/shop/:shop_id/validate_subdomain" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      subdomain = env.params.query.has_key?("subdomain") ? env.params.query["subdomain"] : nil
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil

      begin
        exist_subdomain = DB_K
          .select([
          :subdomain,
          :shop_id,
        ])
          .table(:pages)
          .where(:subdomain, subdomain)
          .first

        if exist_subdomain.empty?
          {subdomain: false}.to_json
        elsif exist_subdomain["shop_id"] === shop_id.not_nil!.to_i
          {subdomain: false}.to_json
        else
          {subdomain: true}.to_json
        end
      rescue exception
        LOGGER.warn("#{exception} No se pudo validar el subdomain")

        env.response.status_code = 403
        {message: "No se pudo validar el subdomain"}
      end
    end

    get "#{url}/shop/:shop_id/validate_domain" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      domain = env.params.query.has_key?("domain") ? env.params.query["domain"] : nil
      shop_id = env.params.url.has_key?("shop_id") ? env.params.url["shop_id"] : nil

      begin
        exist_domain = DB_K
          .select([
          :domain,
          :shop_id,
        ])
          .table(:pages)
          .where(:domain, domain)
          .first

        if exist_domain.empty?
          {domain: false}.to_json
        elsif exist_domain["shop_id"] === shop_id.not_nil!.to_i
          {domain: false}.to_json
        else
          {domain: true}.to_json
        end
      rescue exception
        LOGGER.warn("#{exception} No se pudo validar el domain")

        env.response.status_code = 403
        {message: "No se pudo validar el subdomain"}
      end
    end
  end

  def self.validateField(field, env)
    if field == "accept_card"
      if env.params.json.has_key?("#{field}")
        env.params.json["accept_card"] == true ? true : false
      end
    else
      env.params.json.has_key?("#{field}") ? (field == "phone" || field == "phone2" ? (env.params.json["#{field}"].to_s).to_i : env.params.json["#{field}"].to_s) : ""
    end
  end
end
