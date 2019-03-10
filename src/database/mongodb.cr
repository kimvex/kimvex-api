require "mongo"
require "json"

class MongoDB
  @client : Mongo::Database

  def initialize(url = "", dbName = "")
    @mongo = Mongo::Client.new "mongodb://localhost:27018/"

    @client = @mongo[dbName]
  end

  def insert(collection, values)
    @client["#{collection}"].insert(values)
  end

  def find(query = {} of String => (String | Int32 | Int8 | Int64), collection = "")
    result = [] of JSON::Any
    skip = 0
    limit = 0
    batch_size = 0
    flags = LibMongoC::QueryFlags::NONE
    prefs = nil

    @client[collection].find(
      query,
      BSON.new,
      flags,
      skip,
      limit,
      batch_size,
      prefs
    ) do |doc|
      result << JSON.parse(doc.to_s)
    end

    result
  end

  def find_one(query = [] of Hash::Any, collection = "")
    result = ""
    skip = 0
    limit = 0
    batch_size = 0
    flags = LibMongoC::QueryFlags::NONE
    limit = 0
    prefs = nil

    result = @client["#{collection}"].find_one({"log" => {"$gt" => 1}}, BSON.new, flags, skip, prefs)

    response = {} of String => (String | Int32 | Int8 | Int64)
    puts result
    _to_hash_ = Hash(String, JSON::Any).from_json(result.to_s)

    _to_hash_.each_value do |_to_value_hash|
      response = response.merge(Hash(String, JSON::Any).from_json(_to_value_hash.to_json))
    end
    puts response
    # do |_to_hash__Array|
    #   puts _to_hash__Array
    #   # _to_hash_ = _to_hash__Array
    #   # _to_hash_.each_value do |_to_value_hash|
    #   # end
    # end

    result.not_nil!.each do |values|
      puts values
    end
  end
end
