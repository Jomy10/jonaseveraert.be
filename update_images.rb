# This tools creates new image entries for new files added to assets/images/original

require_relative 'src/lib/image.rb'

pgconn = PG.connect(dbname: "jonaseveraert.be")

process_images(pgconn)
