#!/usr/bin/env ruby
# Html::View::AjaxValues -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'cgi'

module YDIM
	module Html
		module View
class AjaxValues < HtmlGrid::Component
	HTTP_HEADERS = {
		'Content-Type'	=>	'text/javascript; charset=UTF-8',
	}
	def to_html(context)
		"var ajaxResponse = {\n" << @model.collect { |key, val|
			"'#{escape(key)}': '#{escape(val)}'"
		}.join(",\n") << "\n};"
	end
end
		end
	end
end
