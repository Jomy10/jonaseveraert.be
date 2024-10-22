get '/image/gallery/:id' do
  img_id = params["id"].to_i

  puts "ID: #{img_id}"

  path = $db.execute <<-SQL
  select Path
  from Image
  order by CreatedDate desc
  limit 1
  offset #{img_id - 1}
  SQL

  if path.size == 0
    next [404, {}, "Image does not exist"]
  end

  path = File.join "./assets/images/", path[0][0]

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
