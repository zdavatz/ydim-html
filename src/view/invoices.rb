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
		[1,0]	=>	:debitor_name,
		[2,0]	=>	:debitor_email,
		[3,0]	=>	:description,
		[4,0]	=>	:formatted_date,
		[5,0]	=>	:toggle_status,
		[6,0]	=>	:total_netto,
		[7,0]	=>	:pdf,
	}
	CSS_ID = 'invoices'
	CSS_MAP = {
		[6,0]	=>	'right',
	}
	SORT_DEFAULT = :due_date
	links :invoice, :date, :unique_id, :description
	links :debitor, :name, :email
	def compose_components(model, offset)
		@grid.set_row_attributes({'class' => model.payment_status}, offset.at(1))
		super
	end
	def compose_footer(offset)
		label = HtmlGrid::LabelText.new(:total_open_netto, @model, @session, self)
		lpos = column_position(:debitor_name, offset)
		@grid.add(label, *lpos)
		@grid.set_colspan(*lpos.push(2))
		total = @model.inject(0.0) { |sum, invoice|
			unless(invoice.payment_received)
				sum + invoice.total_netto
			else
				sum 
			end
		}
		tpos = column_position(:total_netto, offset)
		@grid.add(total.to_s, *tpos)
		@grid.add_attribute('class', 'right', *tpos)
	end
	def debitor_email(model)
		email(model.debitor)
	end
	def formatted_date(model)
		link = date(model)
		link.value = @lookandfeel.format_date(model.date)
		link
	end
	def column_position(key, offset)
		pos = components.index(key)
		[pos.at(0) + offset.at(0), pos.at(1) + offset.at(1)]
	end
	def debitor_name(model)
		name(model.debitor)
	end
	def formatted_date(model)
		link = date(model)
		link.value = @lookandfeel.format_date(model.date)
		link
	end
	def column_position(key, offset)
		pos = components.index(key)
		[pos.at(0) + offset.at(0), pos.at(1) + offset.at(1)]
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
	private
	def sort_model
		unless(@session.event == :sort)
			null_date = Date.new(9999)
			@model = @model.sort_by { |item| 
				[item.due_date || null_date, item.date || null_date]
			}
		end
	end
end
class Invoices < Template
	CONTENT = InvoiceList
end
		end
	end
end
