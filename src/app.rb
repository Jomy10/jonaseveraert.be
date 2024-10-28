require 'sinatra/base'
require 'erb'
require 'csv'
require 'pg'
require 'concurrent'
require 'concurrent-edge'
require 'rufus-scheduler'

# Lib
require_relative 'lib/html/html.rb'
require_relative 'lib/config.rb'
require_relative 'lib/error.rb'
require_relative 'lib/concurrent/rwlock.rb'
# require_relative 'lib/cleanup_job.rb'

$conf = load_config(ENV["APP_ENV"] || "development")

require_relative 'endpoints/static.rb'
require_relative 'endpoints/image.rb'
require_relative 'endpoints/html.rb'

class Website < Sinatra::Application
  def initialize
    super

    @conf = $conf

    conf_cmd = "init.rb"

    conf_cmd << " -u #{@conf["db_user"]}" unless @conf["db_user"].nil?
    conf_cmd << " -w #{@conf["db_pass"]}" unless @conf["db_pass"].nil?
    conf_cmd << " -h #{@conf["db_host"]}" unless @conf["db_host"].nil?
    conf_cmd << " -p #{@conf["db_port"]}" unless @conf["db_port"].nil?

    ret = system "#{@conf["ruby"]} #{conf_cmd}"
    if !ret
      abort "Initialization failed"
    end

    @site_url = @conf["site_url"]

    # MIME type lookup based on file ext
    @mime_types = {}
    CSV.read("./data/mime_types.csv").each do |csv|
      for file_ext in csv[1..]
        @mime_types[file_ext] = csv[0]
      end
    end

    @layouts = Dir["layouts/*.html"].map do |file|
      [File.basename(file, File.extname(file)), Layout.new(file)]
    end.to_h

    @pages = Dir["pages/*.html"].map do |file|
      [File.basename(file, File.extname(file)), Page.new(file)]
    end.to_h

    @components = Dir["components/*.html"].map do |file|
      [File.basename(file, File.extname(file)), Component.new(file)]
    end.to_h

    @session_storage = {}

    puts "Scheduling session cleanup"
    @scheduler = Rufus::Scheduler.new
    @scheduler.every "5m" do
      Website.cleanup_sessions(@session_storage)
    end
  end

  def self.cleanup_sessions(session_storage)
    # logger.info "Cleaning up sessions..."
    puts "Cleaning up sessions..."

    t = Time.now
    for k, v in session_storage
      p k, v
      elapsed = t - v[:last_access_time]
      next if elapsed > 300 # cleanup every 5 minutes

      lock = v[:session_lock]
      if !lock.acquire_write_lock
        puts "Couldn't  acquire write lock"
        # logger.warn "Couldn't acquire write lock, cleaning up anyway"
      end

      session_storage.delete(k)

      lock.release_write_lock
    end

    puts "Sessions cleaned up"
  end

  def new_pgconnection
    return PG.connect(
      dbname: "jonaseveraert.be",
      host: @conf["db_host"],
      port: @conf["db_port"],
      user: @conf["db_user"],
      password: @conf["db_pass"]
    )
  end

  configure do
    enable :logging, :sessions
    set :port, ($conf["port"] || 8000)
    set :show_exceptions, :after_handler
    # set :scheduler, { Rufus::Scheduler.start_new }
  end

  # Routes that require session storage
  before /\/(image).*/ do
    if @session_storage[session["session_id"]].nil?
      @session_storage[session["session_id"]] = {
        session_lock: RWLock.new,
        last_access_time: Time.now,
        db: self.new_pgconnection,
        db_mutex: Mutex.new
      }
    else
      @session_storage[session["session_id"]][:last_access_time] = Time.now
    end

    if !@session_storage[session["session_id"]][:session_lock].acquire_read_lock
      logger.warn "Couldn't acquire session read lock"
    end
  end

  after /\/(image).*/ do
    if !@session_storage[session["session_id"]][:session_lock].release_read_lock
      logger.warn "Couldn't release session read lock"
    end
  end

  error HTTPError do |e|
    return [e.code, {}, e.message]
  end

  run! if $0 == __FILE__
end
