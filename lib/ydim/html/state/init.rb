#!/usr/bin/env ruby
# encoding: utf-8
# Html::State::Init -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'ydim/html/state/debitors'
require 'ydim/html/view/init'

module YDIM
	module Html
		module State
class Init < SBSM::State 
	VIEW = Html::View::Init
	def login
		if(res = @session.login)
      $stderr.puts "login res is #{@res.inspect}"
			Debitors.new(@session, nil)
    else
      $stderr.puts "Unable to login res is #{@res.inspect}"
      Debitors.new(@session, nil)
		end
	end
end
		end
	end
end
