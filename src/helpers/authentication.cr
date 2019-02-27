class Authentication
  def self.current_session(token)
    token = REDIS.get(token)

    token ? token : 0
  end
end
