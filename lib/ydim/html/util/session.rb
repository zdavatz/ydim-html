#!/usr/bin/env ruby
# encoding: utf-8
# Html::Util::Session -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/session'
require 'ydim/html/state/global'
require 'ydim/html/util/lookandfeel'

module YDIM
	module Html
		module Util
class Session < SBSM::Session
	DEFAULT_LANGUAGE = 'de'
	DEFAULT_STATE = Html::State::Init
	LOOKANDFEEL = Html::Custom::Lookandfeel
	def login
    puts "Trying to login using #{user_input(:email)} #{user_input(:pass)}"
		@app.login(user_input(:email), user_input(:pass))
  rescue => e
    binding.pry
	end
	def invoices
    puts "invoices using #{user_input(:status).inspect}"
		@app.invoice_infos(user_input(:status) || 'is_open')
	end
	def method_missing(meth, *args)
		@app.send(meth, *args)
	end
end
		end
	end
end
