#!/usr/bin/env ruby
# encoding: utf-8
# Html::State::Global -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/state'
require 'ydim/html/state/init'
require 'ydim/html/state/autoinvoice'
require 'ydim/html/state/debitor'
require 'ydim/html/state/debitors'
require 'ydim/html/state/invoice'
require 'ydim/html/state/invoices'
require 'ydim/html/state/pdf'

module YDIM
	module Html
		module State
class Global < SBSM::State
  attr_accessor :sortby, :sort_reverse
	class Stub
		def initialize
			@carry = {}
		end
		def carry(key, val)
			@carry.store(key, val)	
		end
		def method_missing(key, *args)
			if(match = /^(.*)=$/.match(key.to_s))
				@carry[match[1].to_sym] = args.first
			else
				@carry[key]
			end
		end
		def respond_to?(key)
			true
		end
	end
	EVENT_MAP = {
		:debitors	=>	Debitors,
		:invoices	=>	Invoices,
	}
  def autoinvoice
    if(id = @session.user_input(:unique_id))
      AutoInvoice.new(@session, @session.autoinvoice(id))
    end
  end
  def create_autoinvoice
    _create_invoice(CreateAutoInvoice, nil)
  end
	def create_debitor
		Debitor.new(@session, YDIM::Debitor.new(nil))
	end
	def create_invoice
    _create_invoice(CreateInvoice)
	end
  def _create_invoice(nextclass, date=Date.today)
		if((id = @session.user_input(:unique_id)) \
			 && (debitor = @session.debitor(id.to_i)))
			invoice = Stub.new
			invoice.carry(:debitor, debitor)
			invoice.carry(:date, date)
      invoice.carry(:precision, 2)
      if debitor.foreign?
        invoice.carry(:suppress_vat, true)
      end
			nextclass.new(@session, invoice)
		end
  end
	def debitor
		if(id = @session.user_input(:unique_id))
			Debitor.new(@session, @session.debitor(id.to_i))
		end
	end
	def logout
		@session.logout
		State::Init.new(@session, nil)
	end
	def invoice
		if(id = @session.user_input(:unique_id))
			Invoice.new(@session, @session.invoice(id.to_i))
		end
	end
	def pdf
		if(id = @session.user_input(:unique_id))
			Pdf.new(@session, @session.invoice(id.to_i))
		end
	end
	def send_invoice
		if(id = @session.user_input(:unique_id))
      sort_args = { :sortby => (@sortby || []).first,
                    :sort_reverse => @sort_reverse }
			recipients = @session.send_invoice(id.to_i, sort_args)
			message = @session.lookandfeel.lookup(:confirm_send_invoice, recipients)
			Html::State::Confirm.new(@session, message)
		end
	end
end
		end
	end
end
