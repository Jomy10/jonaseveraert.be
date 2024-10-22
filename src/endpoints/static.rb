# Static file serving
get /\/.*\.(txt|js|css|png|jpeg|JPG|ico|woff2|woff|ttf)/ do
  puts "Reading #{request.path_info}"
  file = File.realpath(File.join(".", request.path_info))
  ext = File.extname(file)
  if !File.exist? file
    [404,  {}, "File doesn't exist #{request.path_info}"]
  end
  data = File.read(file)
  content_type = $mime_types[ext[1...]] || FileMagic.new(FileMagic::MAGIC_MIME).file(file)

  [
    200,
    {
      "Content-Type" => content_type
    },
    data
  ]
end
