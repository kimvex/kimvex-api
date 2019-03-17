require "jwt"
require "crypto/bcrypt/password"

class Token
  def self.generateToken(password)
    Time::Location.load("America/Mexico_City")
    payload = {
      :password => password,
      :time     => Time.new,
    }
    JWT.encode(payload, "serviciosK", "HS256")
  end

  def self.decodeToken(token)
    payload = JWT.decode(token, "serviciosK", "HS256")
    payload["password"]
  end

  def self.generatePasswordHash(password)
    key = Crypto::Bcrypt::Password.create(password.to_s, cost: 10)

    key
  end

  def self.verifyPassword(password)
    Crypto::Bcrypt::Password.new(password.to_s)
  end
end
