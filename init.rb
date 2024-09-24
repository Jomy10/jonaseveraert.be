require 'net/http'
require 'sqlite3'

Dir.mkdir("data") unless Dir.exist?("data")

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

if !File.exist?("./data/data.db")
  db = SQLite3::Database.new "./data/data.db"

  db.execute <<-SQL
  create table Metadata (
    Name text primary key not null,
    Value text not null
  );
  SQL

  db.execute "insert into Metadata values ('DB-Version', '1.0');"

  db.execute <<-SQL
  create table Image (
    id integer primary key autoincrement,
    Path text not null unique,
    CreatedDate integer not null default (datetime('now','localtime'))
  );
  SQL

  db.execute <<-SQL
  create index Image_idx1_path on Image(Path);
  SQL
  db.execute <<-SQL
  create index Image_idx2_created on Image(CreatedDate);
  SQL
  db.execute <<-SQL
  create index Image_idx3 on Image(Path, CreatedDate);
  SQL
end
