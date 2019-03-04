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
          accept_card = validateField("accept_card", env)
          list_cards = validateField("list_cards", env)
          type_s = validateField("type_s", env)
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

          DB_K
            .table(:shop)
            .insert([:shop_name, :address, :phone, :phone2, :description, :cover_image, :accept_card, :list_cards, :type_s, :lat, :lon, :score_shop, :user_id], shop)
            .execute

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
      # user_id = Authentication.current_session(env.request.headers["token"])
      shop_result = DB_K
        .select([:*])
        .table(:shop)
        .join(:LEFT, :images_shop, [:url_image], [:shop_id, :shop_id])
        .join(:LEFT, :shop_schedules, [:LUN], [:shop_id, :shop_id])
        .join(:LEFT, :shop_comments, [:comment], [:shop_id, :shop_id])
        .where(:shop_id, shop_id)
        .first

      shop_result
    end
  end

  def self.validateField(field, env)
    if field == "accept_card"
      if env.params.json.has_key?("#{field}")
        env.params.json["accept_card"] == true ? true : false
      end
    else
      env.params.json.has_key?("#{field}") ? (field == "phone" || field == "phone2" ? (env.params.json["#{field}"].to_s).to_i : env.params.json["#{field}"].to_s) : nil
    end
  end
end
