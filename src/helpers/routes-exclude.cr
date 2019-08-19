class ExcludeRoutes
  def self.validateSession(env)
    route = ROUTES_EXCLUDE.find { |route| route == env.request.path }

    begin
      if !route && env.request.headers.has_key?("token") ||
         if !REDIS.get(env.request.headers["token"])
           env.response.status_code = 401
           # env.response.respond_with_error(message = "Without authorization", code = 401)
         end
      else
        if env.request.method != "OPTIONS"
          if !route
            env.response.status_code = 401
          end
        end
      end
    rescue exception
      puts exception
    end
  end

  def self.setAuth(env)
    route = ONLY_ROUTES.find { |route| route == env.request.path }

    if route && env.params.json.has_key?("email") && env.params.json.has_key?("password") && env.request.method == "POST"
      email = env.params.json["email"].as(String)
      password = env.params.json["password"].as(String)

      token = Token.generateToken(password)
      puts token
      # dbr.set(email, token)
      # puts dbr.get(email)
    else
      # ...
      puts "here"
    end
  end
end
