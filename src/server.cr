require "./KemalExtends.cr"
require "./workers.cr"
require "./api/routes.cr"

module Server
  include KExtends

  class KemalServer
    def initialize
      # global = @global
      @Router = ApiRoutes::Router.new("/api")
      # @Router.ApiRoutes
    end

    def run
      cluster = ClusterOfWorkers::Cluster.new(System.cpu_count.to_i)
      cluster.start(Kemal, 3003)
    end
  end
end
