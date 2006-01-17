#!/usr/bin/env ruby
# Html::View::Pdf -- ydim -- 17.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'

module YDIM
	module Html
		module View
class Pdf < HtmlGrid::Component
	HTTP_HEADERS = {
		'Content-Type'	=>	'application/pdf',
	}
	def to_html(context)
		@model.to_pdf
	end
end
		end
	end
end
