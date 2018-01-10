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
        DEFAULT_FLAVOR = "ydim"
        DEFAULT_LANGUAGE = 'de'
        DEFAULT_STATE = Html::State::Init
        LOOKANDFEEL = Html::Custom::Lookandfeel
        def initialize(app:,
                      trans_handler: nil,
                      validator: nil,
                      unknown_user: nil,
                      cookie_name: nil,
                      multi_threaded: true)
          super
          @app = app
        end
        def login
          @app.login(user_input(:email), user_input(:pass))
        end
        def invoices
          @app.root_session.invoice_infos(user_input(:status) || 'is_open')
        end
        def method_missing(meth, *args)
          server = DRbObject.new(nil, YDIM::Html.config.server_url)
          client = YDIM::Client.new(YDIM::Html.config)
          client.login(server, @app.private_key)
          begin
            client.send(meth, *args)
          ensure
            client.logout
          end
        end
      end
    end
  end
end
