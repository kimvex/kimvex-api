class Users
  def self.setPathApi(url : String)
    post "#{url}/users/login" do |env|
      if env.params.json.has_key?("email") && env.params.json.has_key?("password")
        email = env.params.json["email"].as(String)
        password = env.params.json["password"].as(String)

        begin
          user = ""
          # Usersk.find_by(email: email)

          if user && Token.verifyPassword(user) == password
            token = Token.generateToken(password)
            REDIS.set(token, user)
            {token: token.to_s}.to_json
          else
            env.response.status_code = 403
            {message: "Usario o contraseña incorrecto", status: 403}.to_json
          end
        rescue exception
          puts exception
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
          # Usersk.create(fullname: "Granite Rocks!", email: "Check this out.", password: "dsdsd")
          # Usersk.clear
          # user = Usersk.new
          # user.fullname = fullname.to_s
          # user.email = email.to_s
          # user.password = "ssss"
          # # user.create_at = Time.now
          # user.save
          # puts user.errors[0].to_s
          # Validations.field_db(user.errors)

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
        user = ""
        # Usersk.find_by(user_id: user_id ? user_id.to_i : 0)

        if user
          # {
          #   fullname:  user.fullname,
          #   email:     user.email,
          #   phone:     user.phone,
          #   image:     user.image,
          #   create_at: user.create_at,
          # }.to_json
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
