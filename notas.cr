# Geobusqueda en mongodb

def find(querys = [] of Hash::Any, collection = "")
  result = [] of JSON::Any
  skip = 0
  limit = 0
  batch_size = 0
  flags = LibMongoC::QueryFlags::NONE
  prefs = nil

  @client["places"].find({
    "location" => {
      "$near" => {
        "$geometry" => {
          "type"        => "Point",
          "coordinates" => [-73.9667, 40.78],
        },
        "$minDistance" => 1000,
        "$maxDistance" => 5000,
      },
    },
  },
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

# Insertar datos a mongodb
MONGO.insert("shop", {
  "name"     => "Central Park",
  "location" => {"type" => "Point", "coordinates" => [-73.97, 40.77]},
  "category" => "Parks",
})

MONGO.insert("shop", {
  "name"     => "Sara D. Roosevelt Park",
  "location" => {"type" => "Point", "coordinates" => [-73.9928, 40.7193]},
  "category" => "Parks",
})

MONGO.insert("shop", {
  "name"     => "Polo Grounds",
  "location" => {"type" => "Point", "coordinates" => [-73.9375, 40.8303]},
  "category" => "Stadiums",
})
