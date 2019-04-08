require "http/client"

class Users
  def self.setPathApi(url : String)
    post "#{url}/users/login" do |env|
      if env.params.json.has_key?("email") && env.params.json.has_key?("password")
        email = env.params.json["email"].as(String)
        password = env.params.json["password"].as(String)

        begin
          user = DB_K
            .select([:user_id, :password])
            .table(:usersk)
            .where(:email, email)
            .and(:status, 1)
            .first

          if user.empty?
            env.response.status_code = 404
            {message: "El usuario no existe ó no esta verificado", status: 404}.to_json
          elsif user && Token.verifyPassword(user["password"]) == password
            token = Token.generateToken(password)
            REDIS.set(token, user["user_id"])
            {token: token.to_s}.to_json
          else
            env.response.status_code = 403
            {message: "Usario o contraseña incorrecto", status: 403}.to_json
          end
        rescue exception
          LOGGER.warn("#{exception} login")
          {message: "Usario o contraseña incorrecto", status: 401}.to_json
        end
      else
        LOGGER.warn("Error al enviar parametros al iniciar sesión")
        env.response.status_code = 400
      end
    end

    post "#{url}/users/register" do |env|
      if env.params.json.has_key?("email") && env.params.json.has_key?("password") && env.params.json.has_key?("fullname")
        password = env.params.json["password"]
        email = env.params.json["email"]
        fullname = env.params.json["fullname"]
        age = env.params.json.has_key?("age") ? env.params.json["age"].to_s : nil
        phone = env.params.json.has_key?("phone") ? (env.params.json["phone"].to_s).to_i64 : nil
        gender = env.params.json.has_key?("gender") ? env.params.json["gender"].to_s : nil

        token = Token.generatePasswordHash(password)

        begin
          user = [] of DB::Any

          user << fullname.to_s
          user << email.to_s
          user << token.to_s
          user << age
          user << phone
          user << gender
          user << false

          user_id = DB_K
            .table(:usersk)
            .insert([:fullname, :email, :password, :age, :phone, :gender, :status], user)
            .execute

          if !user_id.nil?
            client = HTTP::Client.new("localhost", 3000)
            response = client.post("/api/code_send_mail", headers: HTTP::Headers{"Content-Type" => "application/json"}, form: {"send_to" => email.to_s})
            LOGGER.info(response.body)
          end

          env.response.status_code = 200
          {message: "user create and code verification send", status: 200}.to_json
        rescue exception
          LOGGER.warn("#{exception} > registro")

          env.response.status_code = 500

          {message: "Error al registrarse.", status: 500}.to_json
        end
      else
        LOGGER.warn("Error de parametros en registro")
        env.response.status_code = 400
        {message: "Faltan parametros.", status: 500}.to_json
      end
    end

    get "#{url}/users/profile" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      begin
        user = DB_K
          .select([:fullname, :email, :phone, :age, :gender, :image, :create_at])
          .table(:usersk)
          .where(:user_id, user_id)
          .first
        if user
          user.to_json
        else
          env.response.status_code = 404
          {message: "error with user data"}.to_json
        end
      rescue exception
        LOGGER.warn("#{exception} perfil")

        env.response.status_code = 404
        {message: "error with user data"}.to_json
      end
    end

    put "#{url}/user/update/profile" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      password = env.params.json.has_key?("password") ? env.params.json["password"] : nil
      new_password = env.params.json.has_key?("new_password") ? env.params.json["new_password"] : nil
      email = env.params.json.has_key?("email") ? env.params.json["email"] : nil
      fullname = env.params.json.has_key?("fullname") ? env.params.json["fullname"] : nil
      phone = env.params.json.has_key?("phone") ? (env.params.json["phone"].to_s).to_i64 : nil
      url_image = env.params.json.has_key?("image_url") ? env.params.json["image_url"] : nil
      age = env.params.json.has_key?("age") ? env.params.json["age"].to_s : nil
      gender = env.params.json.has_key?("gender") ? env.params.json["gender"] : nil
      address = env.params.json.has_key?("address") ? env.params.json["address"] : nil

      arr_field_user = [] of String
      arr_data_user = [] of String | Int64

      user = DB_K
        .select([:user_id, :password])
        .table(:usersk)
        .where(:user_id, user_id)
        .first

      begin
        if email
          arr_field_user << "email"
          arr_data_user << email.to_s
        end
        if fullname
          arr_field_user << "fullname"
          arr_data_user << fullname.to_s
        end
        if phone
          arr_field_user << "phone"
          arr_data_user << phone
        end
        if url_image
          arr_field_user << "image"
          arr_data_user << url_image.to_s
        end
        if age
          arr_field_user << "age"
          arr_data_user << age
        end
        if address
          arr_field_user << "address"
          arr_data_user << address.to_s
        end
        if gender
          arr_field_user << "gender"
          arr_data_user << gender.to_s
        end

        if password
          if Token.verifyPassword(user["password"]) == password
            new_password_token = Token.generatePasswordHash(new_password)
            arr_field_user << "password"
            arr_data_user << new_password_token.to_s
          else
            LOGGER.info("Error al contraseña")
            env.response.status_code = 400
            {message: "Contraseña incorrecta"}.to_json
          end
        end

        DB_K
          .table(:usersk)
          .update(arr_field_user, arr_data_user)
          .where(:user_id, user_id)
          .execute

        env.response.status_code = 200
        {message: "Datos actualizados"}.to_json
      rescue exception
        LOGGER.warn("#{exception} Error al actualizar perfil")
        env.response.status_code = 500
        {message: "Error en servidor"}.to_json
      end
    end

    post "#{url}/users/logout" do |env|
      begin
        REDIS.del("#{env.request.headers["token"]}")
        env.response.status_code = 200
        {message: "Sesion cerrada"}.to_json
      rescue exception
        LOGGER.warn("#{exception} logout")

        {message: "Error al cerrar sesion"}.to_json
      end
    end
  end
end
