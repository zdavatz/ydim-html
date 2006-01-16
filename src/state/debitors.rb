#!/usr/bin/env ruby
# Html::State::Debitors -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/debitor'
require 'view/debitors'
require 'ydim/debitor'

module YDIM
	module Html
		module State
class Debitors < Global
	VIEW = Html::View::Debitors
	def init
		@model = @session.debitors
	end
end
		end
	end
end
