#!/usr/bin/env ruby
# encoding: utf-8

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
  'client_url'			=> 'druby://127.0.0.1:0', 
  'config'					=> default_config_files,
  'currency'				=> 'CHF',
  'email'						=> nil,
  'html_url'				=> 'druby://127.0.0.1:12376',
  'http_server'     => 'http://127.0.0.1',
  'log_file'        => $stdout,
  'log_level'       => 'DEBUG',
  'md5_pass'				=> nil,
  'proxy_url'				=> 'druby://127.0.0.1:0',
  'server_url'			=> 'druby://127.0.0.1:12375', 
  'root_key'				=> nil,
  'user'						=> nil,
  'ydim_dir'				=> ydim_default_dir,
 'log_pattern'      => File.join(Dir.pwd, defined?(MiniTest) ? 'test/log' : 'log','/%Y/%m/%d/app_log'),
}
@config = RCLConf::RCLConf.new(ARGV, defaults)
@config.load(@config.config)
	end
end
