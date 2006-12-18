#!/usr/bin/env ruby
# Html::State::Debitor -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'ydim/html/state/global_predefine'
require 'ydim/html/state/ajax_values'
require 'ydim/html/state/invoices'
require 'ydim/html/view/debitor'

module YDIM
	module Html
		module State
class AjaxAutoInvoices < SBSM::State
	VOLATILE = true
	VIEW = Html::View::AutoInvoiceList
end
class Debitor < Global
	include AjaxInvoiceMethods
	attr_reader :model, :autoinvoice_infos, :invoice_infos
	VIEW = Html::View::Debitor
	def init
		super
		load_autoinvoices
		load_invoices
	end
  def ajax_delete_autoinvoice
    if(id = @session.user_input(:unique_id))
      @session.delete_autoinvoice(id)
    end
		AjaxAutoInvoices.new(@session, load_autoinvoices)
  end
	def ajax_invoices
		super(@invoice_infos)
	end
	def generate_invoice
		if(id = @session.user_input(:unique_id))
			Invoice.new(@session, @session.generate_invoice(id.to_i))
		end
	end
	def update
		mandatory = [ :contact, :debitor_type, :email,
			:location, :name, ]
		defaults = {}
		keys = mandatory.dup.push(:address_lines, :contact_firstname,
															:contact_title, :salutation, :phone)
		input = defaults.update(user_input(keys, mandatory))
		unless(error? || @model.unique_id)
			@model = @session.create_debitor
		end
		update_model(input)
		self
	end
	private
  def load_autoinvoices
    invoices = @model.autoinvoice_infos
    @autoinvoice_infos = sort_invoices(currency_convert(invoices))
  end
	def load_invoices
		invoices = @model.invoice_infos(@session.user_input(:status) \
                                    || 'is_open')
		@invoice_infos = sort_invoices(currency_convert(invoices))
	end
	def update_model(input)
		input.each { |key, val|
			@model.send("#{key}=".to_sym, val)
		}
		@model.odba_store if(@model.unique_id)
	end
end
		end
	end
end
