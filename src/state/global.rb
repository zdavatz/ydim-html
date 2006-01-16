#!/usr/bin/env ruby
# Html::State::Global -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/state'
require 'state/init'
require 'state/debitor'
require 'state/debitors'
require 'state/invoice'
require 'state/invoices'

module YDIM
	module Html
		module State
class Global < SBSM::State
	EVENT_MAP = {
		:debitors	=>	Debitors,
		:invoices	=>	Invoices,
	}
	def create_debitor
		Debitor.new(@session, YDIM::Debitor.new(nil))
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
end
		end
	end
end
