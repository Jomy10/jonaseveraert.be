require 'json'

def load_config(mode)
  puts "Reading server config for #{mode}"
  conf = JSON.parse(File.read "server_conf.json")[mode]
  conf["dbname"] ||= "jonaseveraert.be"
  return conf
end
