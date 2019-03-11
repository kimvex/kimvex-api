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

# Busqueda con la libreria
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

# Obtener un dato con alias
# url_image = DB_K
#   .select([:url_image])
#   .table(:images_shop)
#   .where(:shop_id, shop_id)
#   .as_query(:url_image, "url")
#   .execute_query
#   .to_json

# Convertir de hash un json
# shop_result_hash = Hash(String, JSON::Any).from_json(shop_result)
# shop_result_hash["images"] = JSON.parse(url_image)

# Busqueda de tiendas por localizacion
# begin
#   puts MONGO.find({
#     "location" => {
#       "$near" => {
#         "$geometry" => {
#           "type"        => "Point",
#           "coordinates" => ["#{env.params.json["lon"]}".to_f, "#{env.params.json["lat"]}".to_f],
#         },
#         "$minDistance" => 0,
#         "$maxDistance" => 100000,
#       },
#     },
#   }, "shop")
# rescue exception
#   puts exception
# end

# Selecion, insersion y actualización a mysql
# DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").execute_query
# DB_K.table(:usersk).insert([:fullname, :email, :password], ["chomin", "benjamin5@kimvex.com", "sfddsfsdfsdf"]).execute
# DB_K.table(:usersk).update([:fullname, :phone], ["Ben", 333333]).where(:email, "benjamin0@kimvex.com").or(:email, "benjamin3@kimvex.com").execute
# puts DB_K.select([:email, :password, :phone]).table(:usersk).where(:email, "benjamin@kimvex.com").first

# Busqueda en base de datos de la libreria
# @db.query "select * from usersk" do |rs|
#   puts "#{rs.column_name(0)} #{rs.column_name(1)}"
#   rs.each do
#     puts JSON.parse(rs.read(DB::Database))
#     puts rs.read(DB::Any)
#     puts rs.read(String | Int32)
#   end
# end
