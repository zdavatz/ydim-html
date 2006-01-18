#!/usr/bin/env ruby
# Html::View::Confirm -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'view/template'
require 'htmlgrid/div'

module YDIM
	module Html
		module View
class ConfirmComponent < HtmlGrid::Div
	CSS_ID = 'confirm'
	def init
		@value = @model
	end
end
class Confirm < Template
	CONTENT = ConfirmComponent
end
		end
	end
end
