#!/usr/bin/env ruby
# Html::View::Template -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/divtemplate'
require 'view/htmlgrid'
require 'view/navigation'

module YDIM
	module Html
		module View
class Template < HtmlGrid::DivTemplate
	COMPONENTS = {
		[0,0]		=>	'head',
		[0,1]		=>	:content,
		[0,2]		=>	:foot,
		[0,2,2]	=>	:copyright,
	}
	CSS_MAP = ['head', 'content', 'foot',]
	DIV_CLASS = 'template'
	FOOT = Navigation
	def copyright(model, session=@session)
		link = HtmlGrid::Link.new(:copyright, model, @session, self)
		link.href = 'http://www.ywesee.com'
		link
	end
	def other_html_headers(context)
		res = super
		['dojo', 'ydim'].each { |name|
			properties = {
				"language"	=>	"JavaScript",
				"type"			=>	"text/javascript",
				"src"				=>	@lookandfeel.resource_global(:javascript, "#{name}.js"),
			}
			res << context.script(properties)
		}
		res
	end
end
		end
	end
end
