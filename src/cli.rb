require 'optparse'

def get_opts
  options = {}
  OptionParser.new do |opt|
    opt.on("-hHOST", "--host=HOST", "Set the host") do |v|
      options[:host] = v
    end
    opt.on("-fFILE", "--installation-file=FILE", "Keycloak client file") do |v|
      options[:installation_file] = v
    end
    opt.on("-pPORT", "--port=PORT") do |v|
      options[:port] = v.to_i
    end
  end.parse!
  return options
end
