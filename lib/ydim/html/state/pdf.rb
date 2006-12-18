#!/usr/bin/env ruby
# Html::State::Pdf -- ydim -- 17.01.2006 -- hwyss@ywesee.com

require 'ydim/html/view/pdf'

module YDIM
	module Html
		module State
class Pdf < SBSM::State
	VOLATILE = true
	VIEW = Html::View::Pdf
end
		end
	end
end
