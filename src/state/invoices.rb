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
		if(!error? && (invoice = @session.invoice(input[:unique_id].to_i)))
			invoice.payment_received = input[:payment_received]
			invoice.odba_store
		end
		AjaxInvoices.new(@session, model)
	end
end
class Invoices < Global
	include AjaxInvoiceMethods
	VIEW = Html::View::Invoices
	def init
		@model = @session.invoices
	end
end
		end
	end
end
