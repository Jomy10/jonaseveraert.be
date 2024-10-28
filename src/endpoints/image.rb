require 'filemagic'

class Website < Sinatra::Application
  IMG_EXT = ".webp"

  def image_get_name(gallery_id:, session_data:, logger:)
    session_data[:db_mutex].lock
    fetch_filename_sql = <<-SQL
    select FileName
    from Image
    order by CreatedDate desc
    limit 1
    offset $1
    SQL
    path = session_data[:db].exec_params fetch_filename_sql, [gallery_id - 1]
    session_data[:db_mutex].unlock

    raise HTTPError.new(404, "Image does not exist") if path.ntuples == 0

    return path[0]["filename"]
  end

  def read_image(image_path)
    unless File.exist? image_path
      logger.error "Image #{image_path} does not exist"
      raise HTTPError.new(404, "Image does not exist")
    end

    file_data = File.read(image_path)

    raise HTTPError.new(505) if file_data.size == 0

    {
      content_type: @mime_types[IMG_EXT[1...]] || FileMagic.new(FileMagic::MAGIC_MIME).file(image_path),
      image_data: file_data
    }
  end

  get "/image/gallery/:id" do
    img_id = params["id"].to_i

    session_data = @session_storage[session["session_id"]]
    path = File.join "./assets/images/gallery", self.image_get_name(gallery_id: img_id, session_data: session_data, logger: logger) + IMG_EXT
    img = self.read_image(path)

    [
      200,
      { "Content-Type" => img[:content_type] },
      img[:image_data]
    ]
  end

  get "/image/gallery/get_fullscreen/:id" do
    img_id = params["id"].to_i

    session_data = @session_storage[session["session_id"]]
    path = File.join "./assets/images/fullscreen", self.image_get_name(gallery_id: img_id, session_data: session_data, logger: logger) + IMG_EXT
    img = self.read_image(path)

    [
      200,
      { "Content-Type" => img[:content_type] },
      img[:image_data]
    ]
  end
end
