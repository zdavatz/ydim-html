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
			def escaped(*names)
				names.each { |name|
					define_method(name) { |model| 
						escape(model.send(name))
					}
				}
			end
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
		def escape(value)
			CGI.escape(format(value))
		end
		def format(value)
			case value
			when Float
				sprintf("%1.#{self.precision}f", value)
			else 
				value.to_s
			end
		end
		def precision
			mdl = @session.state.model
			if(mdl.respond_to?(:precision))
				mdl.precision
			else
				2
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
		CSS_CLASS = 'large'
	end
	class List
		STRIPED_BG = false
		def List.ajax_inputs(*keys)
			keys.each { |key|
				define_method(key) { |model|
					name = "#{key}[#{model.index}]"
					input = HtmlGrid::InputText.new(name, model, @session, self)
					input.value = format(model.send(key))
					input.css_id = name
					args = [
						:unique_id,	@session.state.model.unique_id,
						:index,			model.index, 
						key,				nil,
					]
					url = @lookandfeel.event_url(:ajax_item, args)
					input.set_attribute('onChange', "reload_data('#{url}' + this.value)")
					input
				}
			}
		end
	end
	class Pass
		CSS_CLASS = 'large'
	end
end
