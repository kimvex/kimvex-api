require "./users.cr"

module ApiRoutes
  class Router
    def initialize(@route : String)
      static_headers do |response, filepath, filestat|
        response.headers.add("Access-Control-Allow-Origin", "*")
      end

      Users.setPathApi(@route)
    end
  end
end
