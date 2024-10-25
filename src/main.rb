require 'sinatra'
require 'erb'
require 'filemagic'
require 'csv'
require 'pg'

require_relative 'lib/config.rb'

conf = load_config(ENV["APP_ENV"] || "development")

conf_cmd = "init.rb"

conf_cmd << " -u #{conf["db_user"]}" unless conf["db_user"].nil?
conf_cmd << " -w #{conf["db_pass"]}" unless conf["db_pass"].nil?
conf_cmd << " -h #{conf["db_host"]}" unless conf["db_host"].nil?
conf_cmd << " -p #{conf["db_port"]}" unless conf["db_port"].nil?

ret = system "ruby #{conf_cmd}"
if !ret
  abort "Initialization failed"
end

# require_relative 'cli'

# options = get_opts

# $port = options[:port] || 6000
# set :port, 6000
# set :environment, :development

$site_url = conf["site_url"]
set :port, conf["port"]

# if (ENV["APP_ENV"] || "development") == "development"
#   $site_url = "http://localhost:#{8000}"
#   set :port, 8000
# elsif ENV["APP_ENV"] == "production"
#   $site_url = "https://jonaseveraert.be"
#   set :port, 6000
# else
#   raise "invalid APP_ENV: #{ENV["APP_ENV"]}"
# end

# $site_url = options[:host] || "http://localhost:#{$port}"
puts "URL = #{$site_url}"
# $db = SQLite3::Database.new "./data/data.db"

# TODO: propper stuff
$db_mutex = Mutex.new
$db = PG.connect(
  dbname: "jonaseveraert.be",
  host: conf["db_host"],
  port: conf["db_port"],
  user: conf["db_user"],
  password: conf["db_pass"]
)

# MIME type lookup based on file ext
$mime_types = {}
CSV.read("./data/mime_types.csv").each do |csv|
  for file_ext in csv[1..]
    $mime_types[file_ext] = csv[0]
  end
end

# $keycloak_client = Keycloak::Client.new(File.read("keycloak.json"))

# Lib
require_relative './lib/page_def.rb'
require_relative './lib/html.rb'

HTMLEndpointBase.init_templates

# Endpoints
# require_relative './endpoints/admin.rb'
require_relative './endpoints/image.rb'
require_relative './endpoints/static.rb'
require_relative './endpoints/html.rb'
