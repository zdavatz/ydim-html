#!/usr/bin/env ruby
# Html::State::Invoices -- ydim -- 13.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/invoices'

module YDIM
	module Html
		module State
class AjaxInvoices < SBSM::State
	VOLATILE = true
	VIEW = Html::View::InvoiceList
end
module AjaxInvoiceMethods
	def ajax_invoices(model=@model)
		keys = [:payment_received, :unique_id]
		input = user_input(keys, keys)
		id = input[:unique_id].to_i
		if(!error? && (invoice = @session.invoice(id)))
			invoice.payment_received = input[:payment_received]
			invoice.odba_store
			model.delete_if { |info| info.unique_id == id }
		end
		AjaxInvoices.new(@session, model)
	end
	def ajax_status
		AjaxInvoices.new(@session, load_invoices)
	end
	def currency_convert(invoices)
		currency = @session.config.currency
		converter = @session.currency_converter
		invoices.each { |inv|
			if(icur = inv.currency)
				inv.total_netto = converter.convert(inv.total_netto, icur, currency)
				inv.total_brutto = converter.convert(inv.total_brutto, icur, currency)
			end
			inv.currency = currency
		}
	end
	def sort_invoices(invoices)
		null_date = Date.new(9999)
		invoices.sort_by { |inv| 
			[null_date - (inv.date || null_date), inv.description.to_s]
		}
	end
end
class Invoices < Global
	include AjaxInvoiceMethods
	VIEW = Html::View::Invoices
	def init
		super
		load_invoices
	end
	private
	def load_invoices
		@model = sort_invoices(currency_convert(@session.invoices))
	end
end
		end
	end
end
