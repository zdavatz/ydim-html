#!/usr/bin/env ruby
# Html::State::Init -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'state/debitors'
require 'view/init'

module YDIM
	module Html
		module State
class Init < SBSM::State 
	VIEW = Html::View::Init
	def login
		if(@session.login)
			Debitors.new(@session, nil)
		end
	end
end
		end
	end
end
