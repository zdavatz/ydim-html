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
	BOOLEAN = [:payment_received, :deleted]
	DATES = [:date, :hosting_invoice_date]
	ENUMS = {
		:currency					=> [ 'CHF', 'EUR', ],
		:debitor_type			=> [ nil, 'dt_hosting', 'dt_pharmacy', 'dt_pharma',
			'dt_insurance', 'dt_info', 'dt_hospital', 'dt_health', 'dt_doctor' ],
		:hosting_invoice_interval => [ 'hinv_3', 'hinv_6', 'hinv_12', ],
		:salutation				=>	[ nil, 'Frau', 'Herr', ],
		:status						=>	[ nil, 'is_open', 'is_due', 'is_paid', 'is_trash'],
	}
	EVENTS = [ :ajax_collect_garbage, :ajax_create_item, :ajax_debitor,
		:ajax_delete_item, :ajax_item, :ajax_invoice, :ajax_invoices, :ajax_status,
		:create_debitor, :create_invoice, :debitor, :debitors, :generate_invoice,
		:invoice, :invoices, :login, :logout, :pdf, :send_invoice, :sort, :update ]
	STRINGS = [ :name, :contact, :contact_firstname, :description, :location,
		:sortvalue, :text, :unit ]
	NUMERIC = [ :unique_id, :hosting_price, :index, :price, :quantity ]
	#future_dates :hosting_invoice_date
	def address_lines(value)
		validate_string(value).split(/\r|\n|\r\n/)
	end
end
		end
	end
end
