class Images
  def self.setPathApi(url : String)
    post "#{url}/images/shop/cover" do |env|
      HTTP::FormData.parse(env.request) do |upload|
        filename = upload.filename
        puts CLOUDINARY.upload(upload, "shop_images")
        # Be sure to check if file.filename is not empty otherwise it'll raise a compile time error
        # if !filename.is_a?(String)
        #   puts "No filename included in upload"
        # else
        #   file_path = ::File.join [Kemal.config.public_folder, "uploads/", filename]
        #   File.open(file_path, "w") do |f|
        #     IO.copy(upload.body, f)
        #   end
        #   "Upload ok"
        # end
      end
    end

    post "#{url}/images/shop/logo" do |env|
    end
  end
end
