#\ -w -p 8050
# 8050 is the port used to serve
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
begin
  require 'pry'
rescue LoadError
end
$stdout.sync = true

trap("USR1") {
  puts "caught USR1 signal, clearing Sessions\n"
  $oddb.clear
}
trap("USR2") {
  puts "caught USR2 signal, flushing stdout...\n"
  $stdout.flush
}

begin
  lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH << lib_dir

  require 'sbsm/logger'
  require 'ydim/html/version'

  $0 = "Ydim-Html"

  load 'ydim/html/config.rb'
  puts "RCLConf uses the first existing files of #{YDIM::Html.config.config.join(',')}"
  YDIM::Html.config.config.each{|file| if File.exist?(file); puts "loaded config from #{file}"; break; end }

  YDIM::Html.config.log_pattern.gsub!('app', $0.to_s)
  SBSM.logger= ChronoLogger.new(YDIM::Html.config.log_pattern)
  # We want to redirect the standard error also to the logger
  # next line found via https://stackoverflow.com/questions/9637092/redirect-stderr-to-logger-instance
  $stderr.reopen SBSM.logger.instance_variable_get(:@logdev).dev

  SBSM.logger.level = Logger::WARN

  require 'ydim/html/util/rack_app'
  require 'ydim/html/util/rack_interface'

  require 'rack'
  require 'rack/static'
  require 'rack/show_exceptions'
  require 'rack'
  require 'webrick'
  require "clogger"
  Rack_And_UserAgent = "$ip - $remote_user [$time_local{%d/%b/%Y %H:%M:%S}] " \
              '"$request" $status $response_length $request_time{4}  "$http_user_agent"'

  use Clogger,
      # ours is Combined + $request_time
      #  LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
      :format =>  Rack_And_UserAgent,
      :logger => SBSM.logger,
      :reentrant => true
  use Clogger, :logger=> $stdout, :reentrant => true
  use(Rack::Static, urls: ["/doc/"])
  use Rack::ContentLength
  SBSM.warn "Starting Rack::Server with log_pattern #{YDIM::Html.config.log_pattern}"

  $stdout.sync = true
  process ||= :ydim_html
  my_app = YDIM::Html::Util::RackInterface.new(app: YDIM::Html::Util::App.new)
rescue  Exception => e
  puts "Error loding required libraries #{e}"
  puts e.backtrace[0..9].join("\n")
  binding.pry
  exit(1)
end

app = Rack::ShowExceptions.new(Rack::Lint.new(my_app))
run app
