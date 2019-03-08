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

DB_K = Database.new
# DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").execute_query
# DB_K.table(:usersk).insert([:fullname, :email, :password], ["chomin", "benjamin5@kimvex.com", "sfddsfsdfsdf"]).execute
# DB_K.table(:usersk).update([:fullname, :phone], ["Ben", 333333]).where(:email, "benjamin0@kimvex.com").or(:email, "benjamin3@kimvex.com").execute
# puts DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").first
REDIS      = RedisDatabase.connect
MONGO      = MongoDB.new("", "kmv")
CLOUDINARY = Cloudinary.new("766496458317643", "h27hacklab")

# MONGO.insert("shop", {
#   "name"     => "Central Park",
#   "location" => {"type" => "Point", "coordinates" => [-73.97, 40.77]},
#   "category" => "Parks",
# })

# MONGO.insert("shop", {
#   "name"     => "Sara D. Roosevelt Park",
#   "location" => {"type" => "Point", "coordinates" => [-73.9928, 40.7193]},
#   "category" => "Parks",
# })

# MONGO.insert("shop", {
#   "name"     => "Polo Grounds",
#   "location" => {"type" => "Point", "coordinates" => [-73.9375, 40.8303]},
#   "category" => "Stadiums",
# })

puts MONGO.find({
  "location" => {
    "$near" => {
      "$geometry" => {
        "type"        => "Point",
        "coordinates" => [-73.9667, 40.78],
      },
      "$minDistance" => 1000,
      "$maxDistance" => 100000,
    },
  },
}, "shop")

ServerSK = Server::KemalServer.new
ServerSK.run
