require 'net/http'
require 'pg'
require 'sem_version'
require 'json'

puts "Initializing..."

Dir.mkdir("data") unless Dir.exist?("data")
Dir.mkdir("assets/images/gallery/") unless Dir.exist?("assets/images/gallery/")
Dir.mkdir("assets/images/original/") unless Dir.exist?("assets/images/original/")
Dir.mkdir("assets/images/fullscreen/") unless Dir.exist?("assets/images/fullscreen/")

# MIME TYPES #

# The version in which to search for the MIME types configuration
MIME_FILE_LINK = "https://raw.githubusercontent.com/patrickmccallum/mimetype-io/refs/heads/master/src/mimeData.json"

uri = URI(MIME_FILE_LINK)
res = Net::HTTP.get_response(uri)
if res.code.to_i == 200
  puts "Received mime types"

  entries = JSON.parse(res.body)

  csv_out = ""
  for entry in entries
    mimetype = entry["name"]
    extensions = entry["fileTypes"]

    for extension in extensions
      csv_out << mimetype
      csv_out << ","
      csv_out << extension[1...]
      csv_out << "\n"
    end
  end

  File.write("data/mime_types.csv", csv_out)
else
  puts "Couldn't get mime types (#{res.code.to_i})"

  if !File.exist?("data/mime_types.csv")
    throw new Error("mime_types.csv couldn't be created")
  end
end

# table_entries = res.body.lines.filter { |l| !l.start_with? "#" }

# csv_txt = table_entries.map do |line|
#   line.split(" ").join(",")
# end


# Image database #

require 'optparse'

db_user = nil
db_pass = nil
db_host = nil
db_port = nil

OptionParser.new do |opts|
  opts.on("-u=USER") do |v|
    db_user = v
  end

  opts.on("-w=PASSWORD") do |v|
    db_pass = v
  end

  opts.on("-h=HOSTNAME") do |v|
    db_host = v
  end

  opts.on("-p=PORT") do |v|
    db_port = v.to_i
  end
end.parse!

pgconn = nil
begin
  pgconn = PG.connect(dbname: "jonaseveraert.be", host: db_host, port: db_port, user: db_user, password: db_pass)
rescue PG::ConnectionBad => e
  ret = system "PGPASSWORD=#{db_pass} /usr/local/bin/createdb -h #{db_host} -p #{db_port} -U #{db_user} jonaseveraert.be"
  if !ret
    abort("Couldn't create database")
  end
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
  values ('DBVersion', '1.0.0');
  SQL
end

if SemVersion.new("1.0.1") > version
  puts "Upgrading to 1.0.1"

  pgconn.exec <<-SQL
  alter type Category add value 'MusicShows';
  SQL

  pgconn.exec <<-SQL
  update Metadata
  set Value = '1.0.1'
  where Name = 'DBVersion'
  SQL
end

puts "All done!"
