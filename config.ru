require_relative './src/lib/config.rb'
$conf = load_config(ENV["APP_ENV"] || "development")

require_relative 'src/app.rb'

# p $conf["port"]
# set :port, $conf["port"]

Rack::Handler.default.run Website, :port => $conf["port"]
