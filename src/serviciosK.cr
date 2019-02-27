require "kemal"
require "redis"

require "./helpers/constant.cr"
require "./helpers/generateToken.cr"
require "./server.cr"
require "./database/mysql.cr"
require "./database/redis.cr"
require "./helpers/authentication.cr"
require "./helpers/validations.cr"

Database.connect
require "./database/models/users.cr"

REDIS = RedisDatabase.connect

ServerSK = Server::KemalServer.new
ServerSK.run
