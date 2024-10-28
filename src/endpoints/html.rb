class Website < Sinatra::Application
  get "/*" do |path|
    ext = File.extname(path)
    unless ext == ".html" || ext == ""
      raise HTTPError.new(400, "File type #{ext} not handled by the server")
    end

    if path == ""
      path = "index"
    end

    page_name = File.basename(path, ext)
    page = @pages[page_name]

    if page == nil
      return [404, {}, "Page #{page_name} does not exist"]
    end

    html = nil

    h = {
      site_url: @site_url,
      session: session,
    }
    h[:components] = ComponentRenderer.new(@components, h)
    begin
      html = page.render(@layouts, h)
    rescue HTTPError => e
      return [e.code, {}, e.message]
    end

    return [
      200,
      { "Content-Type" => "text/html" },
      html
    ]
  end
end
