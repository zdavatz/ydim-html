#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com

require 'find'

here = File.dirname(File.dirname(__FILE__))

$: << here

Find.find(here) { |file|
	if /test_.*\.rb$/o.match(file)
    require file
	end
}
