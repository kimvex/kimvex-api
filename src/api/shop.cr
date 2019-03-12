class Shop
  def self.setPathApi(url : String)
    post "#{url}/shop" do |env|
      begin
        if env.params.json.has_key?("shop_name") && env.params.json.has_key?("address")
          user_id = Authentication.current_session(env.request.headers["token"])
          shop_name = env.params.json["shop_name"]
          address = env.params.json["address"]
          phone = validateField("phone", env)
          phone2 = validateField("phone2", env)
          description = validateField("description", env)
          cover_image = validateField("cover_image", env)
          logo = validateField("logo", env)
          accept_card = validateField("accept_card", env)
          list_cards = validateField("list_cards", env)
          type_s = validateField("type_s", env)
          service_type = validateField("service_type", env)
          lat = validateField("lat", env)
          lon = validateField("lon", env)

          shop = [] of DB::Any

          shop << shop_name.to_s
          shop << address.to_s
          shop << phone
          shop << phone2
          shop << description
          shop << cover_image
          shop << accept_card
          shop << list_cards
          shop << type_s
          shop << lat
          shop << lon
          shop << false
          shop << user_id
          shop << logo

          shop_id_insert = DB_K
            .table(:shop)
            .insert([:shop_name, :address, :phone, :phone2, :description, :cover_image, :accept_card, :list_cards, :type_s, :lat, :lon, :score_shop, :user_id, :logo], shop)
            .execute

          MONGO.insert("shop", {
            "name"     => shop_name.to_s,
            "shop_id"  => shop_id_insert.to_s,
            "location" => {
              "type"        => "Point",
              "coordinates" => ["#{env.params.json["lon"]}".to_f, "#{env.params.json["lat"]}".to_f],
            },
            "category" => type_s.to_s,
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

          if env.params.json.has_key?("service_type")
            DB_K
              .table(:type_service)
              .insert([:service, :shop_id], [service_type, shop_id_insert.to_s])
              .execute
          end

          env.response.status_code = 200
          {message: "Create shop success", status: 200}.to_json
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
          puts error
          env.response.status_code = 500
        end
      end
    end

    get "#{url}/shop/:shop_id" do |env|
      shop_id = env.params.url["shop_id"]
      user_id = Authentication.current_session(env.request.headers["token"])

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
        :type_s,
        :lat,
        :lon,
        :score_shop,
        :status,
      ])
        .table(:shop)
        .join(:LEFT, :images_shop, [:url_image], [:shop_id, :shop_id])
        .join(:LEFT, :shop_schedules, [:LUN, :MAR, :MIE, :JUE, :VIE, :SAB, :DOM], [:shop_id, :shop_id])
        .join(:LEFT, :usersk, [:user_id], [:user_id, :user_id])
        .where(:shop_id, shop_id)
        .and(:user_id, user_id)
        .group_concat([:url_image, :images_shop, :url], :image_id, :images)
        .first

      shop_result
    end
    get "#{url}/shops/:lat/:lon" do |env|
      get_shops = MONGO.aggregate([
        {
          "$geoNear" => {
            "near" => {
              "type"        => "Point",
              "coordinates" => ["#{env.params.url["lon"]}".to_f, "#{env.params.url["lat"]}".to_f],
            },
            "maxDistance"   => 100000,
            "spherical"     => true,
            "distanceField" => "distance",
          },
        },
      ], "shop")

      result_properties = [] of JSON::Any
      values_arr = [] of Int32

      get_shops.map { |value| values_arr << "#{value["shop_id"]}".to_i }

      shops = DB_K
        .select([
        :shop_id,
        :shop_name,
        :address,
        :phone,
        :score_shop,
        :cover_image,
        :type_s,
      ])
        .table(:shop)
        .where_in(:shop_id, values_arr)
        .execute_query

      shops.not_nil!.map { |shop_data|
        hash_match = get_shops.select! { |hash_r| "#{hash_r["shop_id"]}".to_i == shop_data["shop_id"] }
        shop_data["distance"] = hash_match.first["distance"]
      }

      shops.to_json
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
