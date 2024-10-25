# Get an image for display in the photo gallery
get '/image/gallery/:id' do
  img_id = params["id"].to_i

  puts "ID: #{img_id}"

  $db_mutex.lock
  path = $db.exec <<-SQL
  select FileName
  from Image
  order by CreatedDate desc
  limit 1
  offset #{img_id - 1}
  SQL
  $db_mutex.unlock

  p "[#{img_id}] #{path.inspect}"

  if path.ntuples == 0
    next [404, {}, "Image does not exist"]
  end

  p path[0]
  path = File.join "./assets/images/gallery", path[0]["filename"] + ".webp"

  if !File.exist?(path)
    next [404, {}, "Image does not exist"]
  end

  file_data = File.read(path)

  if file_data.size == 0
    next [500, {}, ""]
  end

  mime_type = $mime_types[File.extname(path)[1..].downcase]

  [
    200,
    {"Content-Type" => mime_type},
    file_data
  ]
end
