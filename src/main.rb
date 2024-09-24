$site_url = "http://localhost:4567"

require 'sinatra'
require 'erb'
require 'filemagic'
require 'csv'
require 'sqlite3'
require_relative './page_def.rb'

set :port, 8000

$db = SQLite3::Database.new "./data/data.db"

# MIME type lookup based on file ext
$mime_types = {}
CSV.read("./data/mime_types.csv").each do |csv|
  for file_ext in csv[1..]
    $mime_types[file_ext] = csv[0]
  end
end

# Endpoints
require_relative './image_endpoint.rb'
require_relative './static_endpoint.rb'
require_relative './html_endpoint.rb'
