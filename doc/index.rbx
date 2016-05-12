#!/usr/bin/env ruby
# index.rbx -- ydim-html -- hwyss@ywesee.com

require 'sbsm/request'
load 'etc/config.rb'

::DRb.start_service('druby://localhost:0')

begin
	config = YDIM::Html::Util::CONFIG
	SBSM::Request.new(config.html_url).process
rescue Exception => e
	$stderr << "ydim-html Client Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
