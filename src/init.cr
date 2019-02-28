require "kemal"
require "redis"

require "./helpers/constant.cr"
require "./helpers/generateToken.cr"
require "./server.cr"
require "./database/mysql.cr"
require "./database/redis.cr"
require "./helpers/authentication.cr"
require "./helpers/validations.cr"

DB_K = Database.new
# DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").execute_query
DB_K.table(:usersk).insert([:fullname, :email, :password], ["chomin", "benjamin@kimvex.com", "sfddsfsdfsdf"]).execute
REDIS = RedisDatabase.connect

ServerSK = Server::KemalServer.new
ServerSK.run
