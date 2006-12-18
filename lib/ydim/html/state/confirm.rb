#!/usr/bin/env ruby
# Html::State::Confirm -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'ydim/html/state/global_predefine'
require 'ydim/html/view/confirm'

module YDIM
	module Html
		module State
class Confirm < Global
	VIEW = Html::View::Confirm
end
		end
	end
end
