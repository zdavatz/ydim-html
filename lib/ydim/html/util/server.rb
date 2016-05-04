#!/usr/bin/env ruby
# encoding: utf-8
# Html::Util::Server -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'openssl'
require 'sbsm/drbserver'
require 'ydim/html/util/session'
require 'ydim/html/util/validator'
require 'ydim/client'

module YDIM
	module Html
		module Util
class Server < SBSM::DRbServer
	SESSION = Html::Util::Session
	VALIDATOR = Html::Util::Validator
	def initialize(server)
		@server = server
		@private_key = OpenSSL::PKey::DSA.new(File.read(Html.config.root_key))
		@system = YDIM::Client.new(Html.config)
		super(@system)
	end
	def login(email, pass_hash)
		(email == Html.config.email) && (pass_hash == Html.config.md5_pass)
	end
	def method_missing(meth, *args)
		@system.login(@server, @private_key)
		begin
			@system.send(meth, *args)
		ensure
			@system.logout
		end
	end
end
		end
	end
end
