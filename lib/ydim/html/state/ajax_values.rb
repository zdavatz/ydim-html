#!/usr/bin/env ruby
# encoding: utf-8
# Html::State::AjaxValues -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'sbsm/state'
require 'ydim/html/view/ajax_values'

module YDIM
	module Html
		module State
class AjaxValues < SBSM::State
	VOLATILE = true
	VIEW = Html::View::AjaxValues
end
		end
	end
end
