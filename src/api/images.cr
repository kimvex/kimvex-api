class Images
  def self.setPathApi(url : String)
    post "#{url}/images/shop/cover" do |env|
      response_result = ""
      HTTP::FormData.parse(env.request) do |upload|
        result_cover = CLOUDINARY.upload(upload, "shop_images")
        response_result = JSON.parse(result_cover)
      end

      {result: response_result["url"]}.to_json
    end

    post "#{url}/images/shop" do |env|
      response_result = ""
      HTTP::FormData.parse(env.request) do |upload|
        result_cover = CLOUDINARY.upload(upload, "shop_images")
        response_result = JSON.parse(result_cover)
      end
      {result: response_result["url"]}.to_json
    end

    post "#{url}/images/shop/logo" do |env|
      response_result = ""
      HTTP::FormData.parse(env.request) do |upload|
        result_cover = CLOUDINARY.upload(upload, "logo")
        response_result = JSON.parse(result_cover)
      end
      {result: response_result["url"]}.to_json
    end

    post "#{url}/images/avatar" do |env|
      response_result = ""
      HTTP::FormData.parse(env.request) do |upload|
        result_cover = CLOUDINARY.upload(upload, "avatar")
        response_result = JSON.parse(result_cover)
      end
      {result: response_result["url"]}.to_json
    end
  end
end
