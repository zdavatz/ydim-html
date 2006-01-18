#!/usr/bin/env ruby
# Html::View::Invoices -- ydim -- 13.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/list'
require 'view/template'

module YDIM
	module Html
		module View
class InvoiceList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:unique_id,
		[1,0]	=>	:formatted_date,
		[2,0]	=>	:total_netto,
		[3,0]	=>	:toggle_status,
		[4,0]	=>	:debitor_name,
		[5,0]	=>	:pdf,
	}
	CSS_ID = 'invoices'
	CSS_MAP = {
		[2,0]	=>	'right',
	}
	links :invoice, :date, :unique_id
	links :debitor, :name
	def compose_components(model, offset)
		@grid.set_row_attributes({'class' => model.payment_status}, offset.at(1))
		super
	end
	def debitor_name(model)
		name(model.debitor)
	end
	def formatted_date(model)
		link = date(model)
		link.value = @lookandfeel.format_date(model.date)
		link
	end
	def pdf(model)
		link = HtmlGrid::Link.new(:pdf, model, @session, self)
		link.href = @lookandfeel._event_url(:pdf, {:unique_id => model.unique_id})
		link
	end
	def toggle_status(model)
		key = model.payment_received ? :toggle_unpaid : :toggle_paid
		link = HtmlGrid::Link.new(key, model, @session, self)
		args = {
			:unique_id				=>	model.unique_id,
			:payment_received	=>	!model.payment_received,
		}
		url = @lookandfeel._event_url(:ajax_invoices, args)
		link.href = "javascript: reload_list('invoices', '#{url}')"
		link
	end
end
class Invoices < Template
	CONTENT = InvoiceList
end
		end
	end
end
