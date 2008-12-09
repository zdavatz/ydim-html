#!/usr/bin/env ruby
# Html::State::Debitors -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'ydim/html/state/global_predefine'
require 'ydim/html/state/debitor'
require 'ydim/html/view/debitors'
require 'ydim/debitor'

module YDIM
	module Html
		module State
class AjaxDebitors < SBSM::State
  VOLATILE = true
  VIEW = Html::View::DebitorList
end
class Debitors < Global
	VIEW = Html::View::Debitors
	def init
		@model = @session.debitors
	end
  def ajax_debitors
    filter = @session.user_input(:debitor_type)
    debitors = @model
    if filter
      debitors = debitors.select do |deb| deb.debitor_type == filter end
    end
		AjaxDebitors.new(@session, debitors)
  end
end
		end
	end
end
