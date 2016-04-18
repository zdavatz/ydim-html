#!/usr/bin/env ruby
# encoding: utf-8
# Html::State::Debitors -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'ydim/html/state/global_predefine'
require 'ydim/html/state/debitor'
require 'ydim/html/view/debitors'
require 'ydim/debitor'

module YDIM
	module Html
		module State
class Debitors < Global
	VIEW = Html::View::Debitors
	def init
    lnf = @session.lookandfeel
		@model = @session.debitors.sort_by do |deb|
      [ lnf.lookup(deb.debitor_type) || '', deb.name.to_s.downcase ]
    end
	end
end
		end
	end
end
