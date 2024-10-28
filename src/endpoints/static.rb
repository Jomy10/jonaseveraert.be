require 'filemagic'

class Website < Sinatra::Application
  get /\/.*\.(txt|js|css|png|jpeg|JPG|ico|woff2|woff|ttf)/ do
    return [404, {}, "Invalid path"] unless request.path_info.match? /^(\/node_modules|\/assets|\/favicon.ico)/

    ext = File.extname(request.path_info)
    file = File.join ".", request.path_info
    if !File.exist? file
      [404,  {}, "File doesn't exist #{request.path_info}"]
    end
    data = File.read(file)
    content_type = @mime_types[ext[1...]] || FileMagic.new(FileMagic::MAGIC_MIME).file(file)

    [
      200,
      {
        "Content-Type" => content_type
      },
      data
    ]
  end
end
