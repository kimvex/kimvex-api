require "kemal"
require "redis"
require "http"

require "./helpers/constant.cr"
require "./helpers/generateToken.cr"
require "./server.cr"
require "./database/mysql.cr"
require "./database/redis.cr"
require "./database/mongodb.cr"
require "./helpers/authentication.cr"
require "./helpers/validations.cr"
require "./helpers/cloudinary.cr"
require "./helpers/logger"

LOGGER     = LoggerK.new
DB_K       = Database.new
REDIS      = RedisDatabase.connect
CLOUDINARY = Cloudinary.new("766496458317643", "h27hacklab")
MONGO      = MongoDB.new("", "kmv")

ServerSK = Server::KemalServer.new
ServerSK.run
