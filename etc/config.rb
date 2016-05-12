#!/usr/bin/env ruby
# etc/config -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'rclconf'
require 'digest/md5'

module YDIM
        module Html
                module Util
ydim_default_dir = '/var/ydim/'
if(home = ENV['HOME'])
        ydim_default_dir = File.join(home, '.ydim')
end
default_config_files = [
        File.join(ydim_default_dir, 'ydim-htmld.yml'),
        '/etc/ydim/ydim-htmld.yml',
]
defaults = {
        'config'                                        => default_config_files,
        'client_url'                    => 'druby://localhost:0',
        'currency'                              => 'CHF',
        'email'                                         => 'zdavatz@ywesee.com',
        'html_url'                              => 'druby://localhost:12376',
        'md5_pass'                              => nil,
        'proxy_url'                             => 'druby://localhost:0',
        'server_url'                    => 'druby://localhost:12375', 
        'root_key'                              => '/etc/ydim/id_dsa',
        'user'                                          => nil,
        'ydim_dir'                              => nil,
}
config = RCLConf::RCLConf.new(ARGV, defaults)
config.load(config.config)

CONFIG = config
                end
        end
end

