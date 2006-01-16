#!/usr/bin/env ruby
# Html::View::Invoice -- ydim -- 16.01.2006 -- hwyss@ywesee.com

require 'view/template'
require 'htmlgrid/datevalue'

module YDIM
	module Html
		module View
class ItemList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:time,
		[1,0]	=>	:text,
		[2,0]	=>	:quantity,
		[3,0]	=>	:unit,
		[4,0]	=>	:price,
		[5,0]	=>	:total_netto,
	}
	def time(model)
		@lookandfeel.format_time(model.time)
	end
end
class InvoiceTotalComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:total_netto,
		[0,1]	=>	:vat,
		[0,2]	=>	:total_brutto,
	}
	LABELS = true
end
class InvoiceInnerComposite < HtmlGrid::Composite
	links :debitor, :name
	COMPONENTS = {
		[0,0]	=>	:unique_id,
		[0,1]	=>	:description, 
		[0,2]	=>	:debitor_name,
		[0,3]	=>	:date,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	SYMBOL_MAP = {
		:date	=>	HtmlGrid::DateValue,
	}
	def debitor_name(model)
		link = name(model.debitor)
		link.label = true
		link
	end
end
class InvoiceComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	InvoiceInnerComposite,
		[0,1]	=>	:items,
		[0,2]	=>	InvoiceTotalComposite,
	}
	def items(model)
		ItemList.new(model.items, @session, self)
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
