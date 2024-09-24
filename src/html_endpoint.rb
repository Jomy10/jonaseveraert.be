# Base HTML
base_layout = File.read("./layouts/base.html")
base_template = ERB.new(base_layout)

# Menu bar
menu_items = [
  ["Photo gallery", "/photo-gallery"],
  ["Other projects", "/other-projects"]
]
menu = menu_items.map do |item|
  %(<kor-menu-item label="#{item[0]}" toggle="false" onclick="window.open('#{item[1]}', '_self')"></kor-menu-item>)
end
menu_desktop = menu.join(%(<kor-divider spacing="m" orientation="vertical"></kor-divider>))
menu_mobile = menu.join("")

# Serve HTML (with templating)
get '/*' do |path|
  ext = File.extname(path)
  unless ext == "html" || ext == ""
    raise "Invalid file request"
  end

  if path == ""
    path = "index"
  end
  if ext == ""
    path = path + ".html"
  end
  file_path = File.realpath(File.join("./pages", path))

  # Create HTML
  page_txt = File.read(file_path)
  page_def = PageDefinition.new page_txt

  if page_def.parameters.nil?
    raise "no parameters"
  end

  params = page_def.parameters
  p params
  body = nil #page_def.body
  if params["templating"] == "true"
    body_template = ERB.new(page_def.body)
    body = body_template.result(binding)
  else
    body = page_def.body
  end

  base_template.result(binding)
end
