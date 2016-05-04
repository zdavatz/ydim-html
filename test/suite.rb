#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com

require 'find'

here = File.dirname(File.dirname(__FILE__))
$: << here
require_relative 'selenium'
Find.find(here) do |file|
  if /test_.*\.rb$/o.match(file)
    next if /spec/.match(File.basename(file))
    require file
  end
end
