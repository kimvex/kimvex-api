class RedisDatabase
  def self.connect
    @@redis = Redis.new
  end
end
