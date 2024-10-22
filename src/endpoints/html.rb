
# Serve HTML (with templating)
get '/*' do |path|
  begin
    return [200, {}, HTMLEndpointBase.get_html(path: path)]
  rescue HTTPError => e
    return [e.code, {}, e.msg]
  end
end
