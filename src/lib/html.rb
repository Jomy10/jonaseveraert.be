class HTTPError < StandardError
  attr_accessor :code, :msg

  def initialize(code, msg=nil)
    @code = code
    @msg = msg
  end
end

class HTMLEndpointBase
  def self.init_templates
    # Base HTML layouts
    layouts = {
      "base" => File.read("./layouts/base.html"),
    }
    @@layout_templates = {
      "base" => {
        template: ERB.new(layouts["base"])
      },
      "admin" => {
        template: ERB.new(layouts["base"]),
      }
    }

    # Menu bar
    menu_items = [
      ["Photo gallery", "/photo-gallery"],
      ["Other projects", "/other-projects"]
    ]
    menu = menu_items.map do |item|
      %(<kor-menu-item label="#{item[0]}" toggle="false" onclick="window.open('#{item[1]}', '_self')"></kor-menu-item>)
    end
    @@layout_templates["base"][:menu_desktop] = menu.join(%(<kor-divider spacing="m" orientation="vertical"></kor-divider>))
    @@layout_templates["base"][:menu_mobile] = menu.join("")
  end

  def self.get_html(path:)
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
    f = File.join("./pages", path)
    if !File.exist? f
      raise HTTPError.new(404, "No such file #{f}")
    end
    file_path = File.realpath(f)

    # Create HTML
    page_txt = File.read(file_path)
    page_def = PageDefinition.new page_txt

    if page_def.parameters.nil?
      raise "no parameters"
    end

    params = page_def.parameters
    # p params

    body = nil #page_def.body
    if params["templating"] == "true"
      body_template = ERB.new(page_def.body)
      body = body_template.result(binding)
    else
      body = page_def.body
    end

    selected_layout = params["layout"] || "base"
    # puts "layout = #{selected_layout}"
    menu_desktop = @@layout_templates[selected_layout][:menu_desktop]
    menu_mobile = @@layout_templates[selected_layout][:menu_mobile]

    @@layout_templates[selected_layout][:template].result(binding)
  end
end
