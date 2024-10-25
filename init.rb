require 'net/http'
require 'pg'
require 'sem_version'

puts "Initializing..."

Dir.mkdir("data") unless Dir.exist?("data")
Dir.mkdir("assets/images/gallery/") unless Dir.exist?("assets/images/gallery/")
Dir.mkdir("assets/images/original/") unless Dir.exist?("assets/images/original/")
Dir.mkdir("assets/images/fullscreen/") unless Dir.exist?("assets/images/fullscreen/")

# MIME TYPES #

# The version in which to search for the MIME types configuration
APACHE_VERSION = "2.4.9"
MIME_FILE_LINK = "https://svn.apache.org/viewvc/httpd/httpd/tags/#{APACHE_VERSION}/docs/conf/mime.types?view=co"

uri = URI(MIME_FILE_LINK)
res = Net::HTTP.get_response(uri)

table_entries = res.body.lines.filter { |l| !l.start_with? "#" }

csv_txt = table_entries.map do |line|
  line.split(" ").join(",")
end

File.write("data/mime_types.csv", csv_txt.join("\n"))

# Image database #

require 'optparse'

db_user = nil
db_pass = nil
db_host = nil
db_port = nil

OptionParser.new do |opts|
  opts.on("-u") do |v|
    db_user = v
  end

  opts.on("-w") do |v|
    db_pass = w
  end

  opts.on("-h") do |v|
    db_host = v
  end

  opts.on("-p") do |v|
    db_port = v.to_i
  end
end.parse!

pgconn = nil
begin
    pgconn = PG.connect(dbname: "jonaseveraert.be", host: db_host, port: db_port, user: db_user, password: db_pass)
rescue PG::ConnectionBad => e
  `createdb jonaseveraert.be`
  pgconn = PG.connect(dbname: "jonaseveraert.be", host: db_host, port: db_port, user: db_user, password: db_pass)
end

version = nil
begin
  result = pgconn.exec("select Value from Metadata where name = 'DBVersion'");
  if result.ntuples == 0
    version = nil
  else
    version = SemVersion.new(result[0]["value"])
  end
rescue PG::UndefinedTable => e
  pgconn.exec <<-SQL
  create table Metadata (
    Name text primary key not null,
    Value text not null
  );
  SQL
  version = nil
end

if version.nil?
  puts "Initializing database"
else
  puts "Upgrading database, current version = #{version}"
end

if version.nil?
  pgconn.exec <<-SQL
  create type Category as enum (
    'Street',
    'Landscape',
    'Architecture'
  );
  SQL

  pgconn.exec <<-SQL
  create type Series as enum ();
  SQL

  pgconn.exec <<-SQL
  create table Image (
    Id serial primary key,
    FileName text not null unique,
    Category Category,
    Series Series,
    CreatedDate timestamp with time zone default now()
  );
  SQL

  # Index for order by with newest first
  pgconn.exec <<-SQL
  create index image_timestamp on Image (CreatedDate desc);
  SQL

  pgconn.exec <<-SQL
  insert into Metadata (Name, Value)
  values ('DBVersion', '1.0.0')
  SQL
end

puts "All done!"

# if SemVersion.new("1.0.1") > version
#   puts "yes"
# end
