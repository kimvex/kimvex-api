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
        ExcludeRoutes.validateSession(env)
        # ExcludeRoutes.setAuth(env)
      end

      Users.setPathApi(@route)
      Shop.setPathApi(@route)
      Images.setPathApi(@route)
    end
  end
end
