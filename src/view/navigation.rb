#!/usr/bin/env ruby
# Html::View::Navigation -- ydim -- 13.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/link'

module YDIM
	module Html
		module View
class NavigationLink < HtmlGrid::Link
	def init
		super
		self.value = @lookandfeel.lookup(@name)
		self.href = @lookandfeel._event_url(@name)
	end
end
class Navigation < HtmlGrid::DivComposite
	DIV_ID = 'navigation'
	COMPONENTS = {
		[0,0]	=>	:debitors,
		[1,0]	=>	:invoices,
		[2,0]	=>	:logout,
	}	
	DEFAULT_CLASS = NavigationLink
end
		end
	end
end
