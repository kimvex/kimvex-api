require "kemal"
require "./KemalExtends.cr"
require "./server.cr"

ServerSK = Server::KemalServer.new

ServerSK.run
