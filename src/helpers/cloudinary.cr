class Cloudinary
  @api_key = ""
  @cloud_name = ""
  @folder = ""
  @format = "png"

  def initialize(api_key = "", cloud_name = "")
    @api_key = api_key
    @cloud_name = cloud_name
  end

  def upload(file, folder)
    IO.pipe do |reader, writer|
      channel = Channel(String).new(1)

      spawn do
        HTTP::FormData.build(writer) do |formdata|
          channel.send(formdata.content_type)

          formdata.field("upload_preset", "gjldfc8c")
          formdata.field("folder", folder)
          metadata = HTTP::FormData::FileMetadata.new(filename: file.filename)
          headers = HTTP::Headers{"Content-Type" => "image/png"}
          formdata.file("file", file.body, metadata, headers)
        end

        writer.close
      end

      headers = HTTP::Headers{"Content-Type" => channel.receive, "api_key" => @api_key}
      response = HTTP::Client.post("https://api.cloudinary.com/v1_1/#{@cloud_name}/image/upload", body: reader, headers: headers)

      puts "Response code #{response.status_code}"
      puts "File path: #{response.body}"
      response.body
    end
  end
end
