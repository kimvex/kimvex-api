class Users
  def self.setPathApi(url : String)
    get "#{url}/users/login" do |env|
      "connect"
    end
  end
end
