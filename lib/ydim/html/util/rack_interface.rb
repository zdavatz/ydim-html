#!/usr/bin/env ruby

require 'ydim/html/config'
require 'ydim/root_session'
require 'sbsm/app'

module YDIM
  module Html
    module Util
      class RackInterface < SBSM::RackInterface
        ENABLE_ADMIN = true
        SESSION = Html::Util::Session
        VALIDATOR = Html::Util::Validator
        def initialize(app:,
                      auth: nil,
                      validator: VALIDATOR)
          @app = app
          super(app: app,
                session_class: SESSION,
                # unknown_user: YDIM::UnknownUser.new,
                validator: validator,
                cookie_name: 'oddb.org'
                )
        end
      end
    end
  end
end
