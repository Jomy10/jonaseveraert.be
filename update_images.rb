# This tools creates new image entries for new files added to assets/images/original

require_relative 'src/lib/image.rb'
require_relative 'src/lib/config.rb'

conf = load_config(ENV["APP_ENV"] || "development")

pgconn = PG.connect(
  dbname: "jonaseveraert.be",
  host: conf["db_host"],
  port: conf["db_port"],
  user: conf["db_user"],
  password: conf["db_pass"]
)

process_images(pgconn)
