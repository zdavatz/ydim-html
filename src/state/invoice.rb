#!/usr/bin/env ruby
# Html::State::Invoice -- ydim -- 16.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/invoice'

module YDIM
	module Html
		module State
class Invoice < Global
	VIEW = Html::View::Invoice
end
		end
	end
end
