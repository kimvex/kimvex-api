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
            .first

          if user.empty?
            {message: "El usuario no existe", status: 401}.to_json
          elsif user && Token.verifyPassword(user["password"]) == password
            token = Token.generateToken(password)
            REDIS.set(token, user["user_id"])
            {token: token.to_s}.to_json
          else
            env.response.status_code = 403
            {message: "Usario o contraseña incorrecto", status: 403}.to_json
          end
        rescue exception
          puts "#{exception} login"
          {message: "Usario o contraseña incorrecto", status: 401}.to_json
        end
      else
        env.response.status_code = 400
      end
    end

    post "#{url}/users/register" do |env|
      if env.params.json.has_key?("email") && env.params.json.has_key?("password") && env.params.json.has_key?("fullname")
        password = env.params.json["password"]
        email = env.params.json["email"]
        fullname = env.params.json["fullname"]
        phone = env.params.json.has_key?("phone") ? (env.params.json["phone"].to_s).to_i : nil

        token = Token.generatePasswordHash(password)

        begin
          user = [] of DB::Any

          user << fullname.to_s
          user << email.to_s
          user << token.to_s
          user << phone

          DB_K
            .table(:usersk)
            .insert([:fullname, :email, :password, :phone], user)
            .execute

          env.response.status_code = 200
          {message: "user create", status: 200}.to_json
        rescue exception
          puts "#{exception} > s"

          env.response.status_code = 500

          {message: "#{exception}", status: 500}.to_json
        end
      else
        env.response.status_code = 400
      end
    end

    get "#{url}/users/profile" do |env|
      user_id = Authentication.current_session(env.request.headers["token"])
      begin
        user = DB_K
          .select([:fullname, :email, :phone, :image, :create_at])
          .table(:usersk)
          .where(:user_id, user_id)
          .first

        if user
          user
        else
          env.response.status_code = 404
          {message: "error with user data"}.to_json
        end
      rescue exception
        puts exception

        env.response.status_code = 404
        {message: "error with user data"}.to_json
      end
    end
  end
end
