require_relative 'src/lib/image.rb'

pgconn = PG.connect(dbname: "jonaseveraert.be")

process_images(pgconn)
