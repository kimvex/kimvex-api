require "granite/adapter/mysql"

class Database
  def self.connect
    Granite::Adapters << Granite::Adapter::Mysql.new({name: "mysql", url: "mysql://root@localhost/serviciotest"})
  end
end
