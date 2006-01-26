#!/usr/bin/env ruby
# Html::View::Invoice -- ydim -- 16.01.2006 -- hwyss@ywesee.com

require 'view/template'
require 'htmlgrid/form'
require 'htmlgrid/inputdate'
require 'htmlgrid/errormessage'

module YDIM
	module Html
		module View
class SpanValue < HtmlGrid::Value
	def init
		super
		@attributes.store('id', @name)
	end
	def to_html(context)
		context.span(@attributes) { escape(@value) }
	end
end
class ItemList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:time,
		[1,0]	=>	:text,
		[2,0]	=>	:quantity,
		[3,0]	=>	:unit,
		[4,0]	=>	:price,
		[5,0]	=>	:total_netto,
		[6,0]	=>	:delete,
	}
	CSS_ID = 'items'
	CSS_MAP = {
		[0,0]	=>	'standard-width',
		[5,0]	=>	'right',
	}
	COMPONENT_CSS_MAP = {
		[2,0,3]	=>	'small'
	}
	DEFAULT_CLASS = HtmlGrid::InputText
	SYMBOL_MAP = {
		:total_netto =>	SpanValue,
	}
	ajax_inputs :text, :quantity, :unit, :price
	def compose_footer(offset)
		link = HtmlGrid::Button.new(:create_item, @model, @session, self)
		args = { :unique_id => @session.state.model.unique_id }
		url = @lookandfeel.event_url(:ajax_create_item, args)
		link.set_attribute('onClick', "reload_list('items', '#{url}');")
		@grid.add(link, *offset)
	end
	def delete(model)
		link = HtmlGrid::Link.new(:delete, model, @session, self)
		args = {
			:unique_id	=>	@session.state.model.unique_id,
			:index			=>	model.index,
		}
		url = @lookandfeel.event_url(:ajax_delete_item, args)
		link.href = "javascript: reload_list('items', '#{url}')"
		link
	end
	def time(model)
		if(time = model.time)
			@lookandfeel.format_time(model.time)
		end
	end
	def total_netto(model)
		val = SpanValue.new(:total_netto, model, @session, self)
		val.css_id = "total_netto#{model.index}"
		val
	end
end
class InvoiceTotalComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:total_netto,
		[0,1]	=>	:vat,
		[0,2]	=>	:total_brutto,
	}
	CSS_ID = 'total'
	CSS_MAP = {
		[1,0,1,2]	=>	'right',
		[2,0]			=>	'right total',
	}
	DEFAULT_CLASS = SpanValue
	LABELS = true
end
class InvoiceInnerComposite < HtmlGrid::Composite
	include HtmlGrid::ErrorMessage
	links :debitor, :name, :email
	COMPONENTS = {
		[0,0]		=>	:unique_id,
		[0,2]		=>	:debitor_name,
		[1,2,0]	=>	'dash', 
		[1,2,1]	=>	:debitor_email,
		[0,1]		=>	:description, 
		[0,3]		=>	:date,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:date					=>	HtmlGrid::InputDate,
		:description	=>	HtmlGrid::InputText,
	}
	def init
		super
		error_message
	end
	def debitor_email(model)
		email(model.debitor)
	end
	def debitor_name(model)
		link = name(model.debitor)
		link.label = true
		link
	end
end
class InvoiceComposite < HtmlGrid::DivComposite
	include HtmlGrid::FormMethods
	COMPONENTS = {
		[0,0]	=>	InvoiceInnerComposite,
		[0,1]	=>	:items,
		[0,2]	=>	InvoiceTotalComposite,
		[0,3]	=>	:submit,
		[1,3]	=>	:pdf,
		[2,3]	=>	:send_invoice,
	}
	CSS_MAP = {
		3	=>	'padded'
	}
	EVENT = :update
	def init
		if(@model.unique_id.nil?)
			@components = {
				[0,0]	=>	InvoiceInnerComposite,
				[0,1]	=>	:submit,
			}
			@css_map = { 1 => 'padded' }
		elsif(@model.items.empty?)
			@components = {
				[0,0]	=>	InvoiceInnerComposite,
				[0,1]	=>	:items,
				[0,2]	=>	:submit,
			}
			@css_map = { 2 => 'padded' }
		end
		super
	end
	def hidden_fields(context)
		super << context.hidden('unique_id', @model.unique_id)
	end
	def items(model)
		ItemList.new(model.items, @session, self)
	end
	def pdf(model)
		button = HtmlGrid::Button.new(:pdf, model, @session, self)
		url = @lookandfeel._event_url(:pdf, {:unique_id => model.unique_id})
		button.set_attribute('onClick', "document.location.href='#{url}'")
		button
	end
	def send_invoice(model)
		button = HtmlGrid::Button.new(:send_invoice, model, @session, self)
		url = @lookandfeel._event_url(:send_invoice, {:unique_id => model.unique_id})
		button.set_attribute('onClick', "document.location.href='#{url}'")
		button
	end
end
class Invoice < Template
	CONTENT = InvoiceComposite
	def init
		css_map[1] = @model.payment_status
		super
	end
end
		end
	end
end
