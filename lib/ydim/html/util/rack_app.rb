#!/usr/bin/env ruby
require 'syck'
require 'openssl'
require 'sbsm/app'
require 'ydim/client'
require 'ydim/html'
require 'ydim/html/version'
require 'ydim/html/util/lookandfeel'
require 'ydim/html/util/validator'
require 'ydim/html/util/session'
require 'ydim/odba'
require 'ydim/invoice'
require 'ydim/debitor'

require 'sbsm/session'
require 'sbsm/app'

module YDIM
  module Html
    module Util
      class App < SBSM::App
        attr_reader :ydim_server, :root_session, :private_key
        def initialize
            SBSM.logger= ChronoLogger.new(YDIM::Html.config.log_pattern)
            SBSM.logger.level = :debug
            ydim_html_version = `git rev-parse HEAD`.chomp
            msg = "YDIM::Html::Util::App #{ydim_html_version} used version: sbsm #{SBSM::VERSION}, ydim #{YDIM::Html::VERSION}, ydbi #{DBI::VERSION}"
            puts msg
            SBSM.logger.info(msg)
            SBSM.logger.info "Starting Rack-Service #{self.class} and service #{YDIM::Html.config.server_url}"
            @system = YDIM::Client.new(Html.config)
            @private_key = OpenSSL::PKey::DSA.new(File.read(Html.config.root_key))
            @ydim_server = DRb::DRbObject.new(nil, YDIM::Html.config.server_url)
            super()
          end
          def login(email, pass_hash)
            (email == Html.config.email) && (pass_hash == Html.config.md5_pass)
          end
        end
      end
    end
  end
