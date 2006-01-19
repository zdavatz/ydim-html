#!/usr/bin/env ruby
# Html::State::Global -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/state'
require 'state/init'
require 'state/debitor'
require 'state/debitors'
require 'state/invoice'
require 'state/invoices'
require 'state/pdf'

module YDIM
	module Html
		module State
class Global < SBSM::State
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
	def create_debitor
		Debitor.new(@session, YDIM::Debitor.new(nil))
	end
	def create_invoice
		if((id = @session.user_input(:unique_id)) \
			 && (debitor = @session.debitor(id.to_i)))
			invoice = Stub.new
			invoice.carry(:debitor, debitor)
			CreateInvoice.new(@session, invoice)
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
end
		end
	end
end
