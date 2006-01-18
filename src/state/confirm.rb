#!/usr/bin/env ruby
# Html::State::Confirm -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/confirm'

module YDIM
	module Html
		module State
class Confirm < Global
	VIEW = Html::View::Confirm
end
		end
	end
end
