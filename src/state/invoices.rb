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
end
class Invoices < Global
	include AjaxInvoiceMethods
	VIEW = Html::View::Invoices
	def init
		super
		null_date = Date.new(9999)
		@model = @session.invoices.sort_by { |item| 
			[item.due_date || null_date, item.date || null_date]
		}
	end
end
		end
	end
end
