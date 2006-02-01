#!/usr/bin/env ruby
# Html::Util::Server -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'openssl'
require 'sbsm/drbserver'
require 'util/session'
require 'util/validator'
require 'ydim/client'

module YDIM
	module Html
		module Util
class Server < SBSM::DRbServer
	SESSION = Html::Util::Session
	VALIDATOR = Html::Util::Validator
	attr_reader :config
	def initialize(config, server)
		@config = config
		@server = server
		@private_key = OpenSSL::PKey::DSA.new(File.read(@config.root_key))
		@system = YDIM::Client.new(@config)
		super(@system)
	end
	def login(email, pass_hash)
		email == @config.email && pass_hash = @config.md5_pass
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
