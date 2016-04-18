#!/usr/bin/env ruby
# encoding: utf-8
# Html::View::Confirm -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'ydim/html/view/template'
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
	def http_headers
		headers = super
		url = @lookandfeel._event_url(:invoices)
		headers.store('Refresh', "5; URL=#{url}")
		headers
	end
end
		end
	end
end
