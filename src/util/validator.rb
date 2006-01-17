#!/usr/bin/env ruby
# Html::Util::Validator -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/validator'

module YDIM
	module Html
		module Util
class Validator < SBSM::Validator
	class << self
		def future_dates(*names)
			names.each { |name|
				define_method(name) { |value| 
					valid = validate_date(name, value)
					return if valid.nil?
					if(valid <= Date.today)
						raise SBSM::InvalidDataError.new(:e_bygone_date, name, value)
					end
					valid
				}
			}
		end
	end
	BOOLEAN = [:payment_received]
	ENUMS = {
		:debitor_type			=> [ nil, 'dt_hosting', 'dt_pharma', 'dt_insurance',
			'dt_info', ],
		:hosting_invoice_interval => [ 'hinv_3', 'hinv_6', 'hinv_12', ],
	}
	EVENTS = [ :ajax_debitor, :ajax_invoices, :create_debitor, :create_invoice,
		:debitor, :debitors, :invoice, :invoices, :login, :logout, :sort, :update ]
	STRINGS = [ :name, :contact, :location, :sortvalue ]
	NUMERIC = [ :unique_id, :hosting_price ]
	future_dates :hosting_invoice_date
	def address_lines(value)
		validate_string(value).split(/\r|\n|\r\n/)
	end
end
		end
	end
end
