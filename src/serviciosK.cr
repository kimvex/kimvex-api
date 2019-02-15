require "kemal"
require "./server.cr"

ServerSK = Server::KemalServer.new

ServerSK.run
