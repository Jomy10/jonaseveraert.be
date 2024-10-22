require 'sinatra'
require 'erb'
require 'filemagic'
require 'csv'
require 'sqlite3'
require 'libkeycloak'

require_relative 'cli'

options = get_opts

$port = options[:port] || 6000
set :port, $port

$site_url = options[:host] || "http://localhost:#{$port}"
$db = SQLite3::Database.new "./data/data.db"

# MIME type lookup based on file ext
$mime_types = {}
CSV.read("./data/mime_types.csv").each do |csv|
  for file_ext in csv[1..]
    $mime_types[file_ext] = csv[0]
  end
end

$keycloak_client = Keycloak::Client.new(File.read("keycloak.json"))


# Lib
require_relative './page_def.rb'
require_relative './html.rb'

HTMLEndpointBase.init_templates

# Endpoints
require_relative './endpoints/admin.rb'
require_relative './endpoints/image.rb'
require_relative './endpoints/static.rb'
require_relative './endpoints/html.rb'
