class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "auth #{env}"

    @app.call(env)
  end
end

post "/admin/logged-in" do
  user = params["uname"]
  pass = params["pass"]

  tokens = $keycloak_client.get_token(user, pass, scopes: ["openid"])

  return [301, {
    "Location" => "#{$site_url}/admin",
    "Access-Token" => tokens.access_token.to_h,
    "Refresh-Token" => tokens.refresh_token.to_h,
  }, ""]
end

# class Admin < Sinatra::Base
#   use AuthMiddleware

  get "/admin" do
    p params
    return [200, {}, "OK"]
  end
# end

# run Admin.new
