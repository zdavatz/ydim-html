#!/usr/bin/env ruby
# HtmlGrid -- ydim -- 13.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/composite'
require 'htmlgrid/errormessage'
require 'htmlgrid/form'
require 'htmlgrid/input'
require 'htmlgrid/inputtext'
require 'htmlgrid/list'
require 'htmlgrid/pass'

module HtmlGrid
	class Component
		class << self
			def links(event, *names)
				names.each { |name|
					define_method(name) { |model| 
						link = HtmlGrid::Link.new(name, model, @session, self)
						args = {:unique_id => model.unique_id}
						link.href = @lookandfeel._event_url(event, args)
						link.value = model.send(name)
						link
					}
				}
			end
		end
	end
	class Composite 
		LEGACY_INTERFACE = false
	end
	class Form 
		include HtmlGrid::ErrorMessage
		DEFAULT_CLASS = HtmlGrid::InputText
		LABELS = true
		def init
			super
			error_message
		end
	end
	class InputText
		CSS_CLASS = 'text'
	end
	class List
		STRIPED_BG = false
	end
	class Pass
		CSS_CLASS = 'text'
	end
end
