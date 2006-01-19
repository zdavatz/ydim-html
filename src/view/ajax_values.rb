#!/usr/bin/env ruby
# Html::View::AjaxValues -- ydim -- 18.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'

module YDIM
	module Html
		module View
class AjaxValues < HtmlGrid::Component
	HTTP_HEADERS = {
		'Content-Type'	=>	'text/javascript',
	}
	def to_html(context)
		"var ajaxResponse = {\n" << @model.collect { |key, val|
			"'#{key}': '#{val}'"
		}.join(",\n") << "\n};"
	end
end
		end
	end
end
