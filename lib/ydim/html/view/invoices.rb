#!/usr/bin/env ruby
# encoding: utf-8
# Html::View::Invoices -- ydim -- 13.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/list'
require 'ydim/html/view/template'

module YDIM
	module Html
		module View
class InvoiceList < HtmlGrid::List
	COMPONENTS = {
		[0,0]		=>	:unique_id,
		[1,0]		=>	:name,
		[2,0]		=>	:email,
		[3,0]		=>	:description,
		[4,0]		=>	:formatted_date,
		[5,0]		=>	:toggle_payment_received,
		[6,0]		=>	:total_netto,
		[7,0]		=>	:total_brutto,
		[8,0]		=>	:currency,
		[9,0]		=>	:send_invoice,
		[10,0]	=>	:pdf,
		[11,0]	=>	:toggle_deleted,
	}
	CSS_ID = 'invoices'
	CSS_MAP = {
		[6,0,2]	=>	'right',
	}
	SORT_DEFAULT = nil
	class << self
		def debitor_links(*names)
			names.each { |name|
				define_method(name) { |model|
					link = HtmlGrid::Link.new(name, model, @session, self)
					link.href = @lookandfeel._event_url(:debitor, 
																							{:unique_id => model.debitor_id})
					str = model.send("debitor_#{name}").to_s
					if(str.length > 30)
						str = str[0,27] << '...'
					end
					link.value = str
					link
				}
			}
		end
		def toggle(name, on, off)
			define_method("toggle_#{name}") { |model|
				current = model.send(name)
				key = current ? off : on
				link = HtmlGrid::Link.new(key, model, @session, self)
				args = {
					:unique_id				=>	model.unique_id,
					name							=>	!current,
				}
				url = @lookandfeel._event_url("ajax_#{css_id}", args)
				link.href = "javascript: reload_list('#{css_id}', '#{url}')"
				link
			}
		end
	end
	links :invoice, :date, :unique_id, :description
	debitor_links :name, :email
	escaped :total_netto, :total_brutto
	toggle :deleted, :toggle_deleted, :toggle_recovered
	toggle :payment_received, :toggle_paid, :toggle_unpaid
	def row_css(model, bg_flag)
    [super, model.status].compact.join(' ')
	end
	def compose_footer(offset)
		garbage = false
		netto = 0.0
		brutto = 0.0
		total = @model.each { |invoice|
			garbage = true if(invoice.deleted)
			netto += invoice.total_netto
			brutto += invoice.total_brutto
		}
		if(garbage)
			button = HtmlGrid::Button.new(:collect_garbage, @model, @session, self)
			url = @lookandfeel._event_url(:ajax_collect_garbage)
			button.set_attribute('onClick', "reload_list('invoices', '#{url}');")
			@grid.add(button, *offset)
			@grid.set_colspan(*offset)
		else
			label = HtmlGrid::LabelText.new(:total, @model, @session, self)
			lpos = column_position(:name, offset)
			@grid.add(label, *lpos)
			@grid.set_colspan(*lpos.push(2))
			total(:total_netto, netto, offset)
			total(:total_brutto, brutto, offset)
			lpos = column_position(:currency, offset)
			@grid.add(Html.config.currency, *lpos)
		end
	end
	def total(key, total, offset)
		tpos = column_position(key, offset)
		@grid.add(number_format(format(total)), *tpos)
		@grid.add_attribute('class', 'right total', *tpos)
	end
	def column_position(key, offset)
		pos = components.key(key)
		[pos.at(0) + offset.at(0), pos.at(1) + offset.at(1)]
	end
	def formatted_date(model)
		if(date = model.date)
			link = date(model)
			link.value = @lookandfeel.format_date(date)
			link
		end
	end
	def pdf(model)
		link = HtmlGrid::Link.new(:pdf, model, @session, self)
		link.href = @lookandfeel._event_url(:pdf, {:unique_id => model.unique_id})
		link
	end
	def send_invoice(model)
		if(model.status == 'is_due')
			link = HtmlGrid::Link.new(:send_invoice, model, @session, self)
			link.href = @lookandfeel._event_url(:send_invoice, 
																					{:unique_id => model.unique_id})
			link
		end
	end
end
class InvoicesSubnavigation < HtmlGrid::DivComposite
	def InvoicesSubnavigation.status_links(*names)
		names.each { |name|
			define_method(name) { |model|
				link = HtmlGrid::Link.new(name, model, @session, self)
				url = @lookandfeel._event_url(:ajax_status, {:status => name })
				link.href =	"javascript:reload_list('invoices', '#{url}');"
				link
			}
		}
	end
	status_links :is_open, :is_paid, :is_due, :is_trash
	COMPONENTS = {
		[0,0]	=>	:is_open,
		[1,0]	=>	:is_due,
		[2,0]	=>	:is_paid,
		[3,0]	=>	:is_trash,
	}
	CSS_ID_MAP = ['subnavigation']
end
class InvoicesComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	InvoiceList,
	}
end
class Invoices < Template
	CONTENT = InvoicesComposite
	def subnavigation(model)
		InvoicesSubnavigation.new(model, @session, self)
	end
end
		end
	end
end
