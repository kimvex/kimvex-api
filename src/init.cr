require "./database/mongodb.cr"
MONGO = MongoDB.new("", "kmv")

require "kemal"
require "redis"
require "http"

require "./api/tetris.cr"

require "./helpers/constant.cr"
require "./helpers/generateToken.cr"
require "./server.cr"
require "./database/mysql.cr"
require "./database/redis.cr"
require "./helpers/authentication.cr"
require "./helpers/validations.cr"
require "./helpers/cloudinary.cr"

DB_K = Database.new
# DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").execute_query
# DB_K.table(:usersk).insert([:fullname, :email, :password], ["chomin", "benjamin5@kimvex.com", "sfddsfsdfsdf"]).execute
# DB_K.table(:usersk).update([:fullname, :phone], ["Ben", 333333]).where(:email, "benjamin0@kimvex.com").or(:email, "benjamin3@kimvex.com").execute
# puts DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").first
REDIS      = RedisDatabase.connect
CLOUDINARY = Cloudinary.new("766496458317643", "h27hacklab")

ServerSK = Server::KemalServer.new
ServerSK.run
