#!/usr/bin/env ruby
# Html::View::Template -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/divtemplate'
require 'htmlgrid/span'
require 'view/htmlgrid'
require 'view/navigation'

module YDIM
	module Html
		module View
class Template < HtmlGrid::DivTemplate
	COMPONENTS = {
		[0,0]		=>	:subnavigation,
		[1,0]		=>	:foot,
		[0,1]		=>	:content,
		[0,2]		=>	:version,
		[1,2]		=>	'ydim',
	}
	CSS_MAP = ['head', 'content', 'foot',]
	DIV_CLASS = 'template'
	FOOT = Navigation
	LEGACY_INTERFACE = false
	def content(model)
		@content ||= super
	end
	def cpr_link(model)
		link = standard_link(:cpr_link, model)
		link.href = 'http://www.ywesee.com'
		link
	end
	def current_year(model)
		Time.now.year.to_s
	end
	def lgpl_license(model)
		link = standard_link(:lgpl_license, model)
		link.href = 'http://www.gnu.org/copyleft/lesser.html'
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
	def standard_link(key, model)
		HtmlGrid::Link.new(key, model, @session, self)
	end
	def version(model)
		span = HtmlGrid::Span.new(model, @session, self)
		span.css_id = 'version'
		span.value = [ 
			lgpl_license(model), @lookandfeel.lookup('comma'), Time.now.year.to_s,
			cpr_link(model), @lookandfeel.lookup('comma'), ydim_version(model),
		]
		span
	end
	def ydim_version(model)
		link = standard_link(:ydim_version, model)
		link.href = 'http://scm.ywesee.com/?p=ydim-html;a=summary'
		link.set_attribute('title', YDIM_VERSION)
		link
	end
end
		end
	end
end
