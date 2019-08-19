require "./users.cr"
require "./shop.cr"
require "./images.cr"
require "../helpers/routes-exclude"

module ApiRoutes
  class Router
    def initialize(@route : String)
      static_headers do |response, filepath, filestat|
        response.headers.add("Access-Control-Allow-Origin", "*")
      end

      # options "/*" do |env|
      #   env.response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
      #   env.response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
      # end
      {% for http_path in OPTIONS_HTTP_ALLOW %}
        options "#{{{ http_path }}}" do |env|
          # env.response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
          # env.response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
        end
      {% end %}

      error 404 do
        {message: "Does not exist", status: 404}.to_json
      end

      error 401 do
        {message: "Not authorization", status: 401}.to_json
      end

      error 400 do
        {message: "Error on params", status: 400}.to_json
      end

      before_all do |env|
        env.response.headers["Access-Control-Allow-Origin"] = "*"
        env.response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
        env.response.headers["Access-Control-Allow-Methods"] = "GET, HEAD, POST, PUT, DELETE"
        env.response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, token"
        ExcludeRoutes.validateSession(env)
        # ExcludeRoutes.setAuth(env)
      end

      Users.setPathApi(@route)
      Shop.setPathApi(@route)
      Images.setPathApi(@route)
    end
  end
end
