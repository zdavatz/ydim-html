#!/usr/bin/env ruby
# encoding: utf-8
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
    if @model.is_a?(Array)
      "var ajaxResponse = {\n" << @model.collect { |key, val|
        "'#{escape(key)}': '#{escape(val)}'"
      }.join(",\n") << "\n};"
    else
      "var ajaxResponse = {\n'" << escape(@model.to_s) + "'\n};"
    end
	end
end
		end
	end
end
