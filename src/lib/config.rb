require 'json'

def load_config(mode)
  puts "Reading server config for #{mode}"
  conf = JSON.parse(File.read "server_conf.json")[mode]
  conf["dbname"] ||= "jonaseveraert.be"
  conf["db_pass"] = conf["db_pass"].nil? ? nil : ENV[conf["db_pass"]["env"]]
  if conf["db_pass"] == ""
    conf["db_pass"] = nil
  end
  return conf
end
