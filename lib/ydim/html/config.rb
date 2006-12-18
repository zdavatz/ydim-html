#!/usr/bin/env ruby
# Html.config -- ydim -- 14.12.2006 -- hwyss@ywesee.com

require 'rclconf'
require 'ydim/html'

module YDIM
	module Html
ydim_default_dir = '/var/ydim/'
if(home = ENV['HOME'])
  ydim_default_dir = File.join(home, '.ydim')
end
default_config_files = [
 'etc/ydim-htmld.yml',
  File.join(ydim_default_dir, 'ydim-htmld.yml'),
  '/etc/ydim/ydim-htmld.yml',
]
defaults = {
  'client_url'			=> 'druby://localhost:0', 
  'config'					=> default_config_files,
  'currency'				=> 'CHF',
  'email'						=> nil,
  'html_url'				=> 'druby://localhost:12376',
  'http_server'     => 'http://localhost',
  'log_file'        => $stdout,
  'log_level'       => 'DEBUG',
  'md5_pass'				=> nil,
  'proxy_url'				=> 'druby://localhost:0',
  'server_url'			=> 'druby://localhost:12375', 
  'root_key'				=> nil,
  'user'						=> nil,
  'ydim_dir'				=> ydim_default_dir,
}
@config = RCLConf::RCLConf.new(ARGV, defaults)
@config.load(@config.config)
	end
end
