#!/usr/bin/env ruby
# Html::Util::Session -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/session'
require 'state/global'
require 'custom/lookandfeel'

module YDIM
	module Html
		module Util
class Session < SBSM::Session
	DEFAULT_LANGUAGE = 'de'
	DEFAULT_STATE = Html::State::Init
	LOOKANDFEEL = Html::Custom::Lookandfeel
	def login
		@app.login(user_input(:email), user_input(:pass))
	end
	def invoices
		@app.invoice_infos(user_input(:status) || 'is_open')
	end
	def method_missing(meth, *args)
		@app.send(meth, *args)
	end
end
		end
	end
end
