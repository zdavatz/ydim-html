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
		[0,0]		=>	:subnavigation,
		[1,0]		=>	'head',
		[0,1]		=>	:content,
		[0,2]		=>	:foot,
		[1,2]		=>  :lgpl_license,
		[2,2]		=>  'comma',
		[3,2]		=>  :current_year,
		[4,2]		=>	:cpr_link,
		[5,2]		=>  'comma',
		[6,2]		=>	:ydim_version,
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
