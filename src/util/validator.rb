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
			'dt_insurance', 'dt_info', 'dt_hospital', 'dt_health', 'dt_doctor',
      'dt_consulting' ],
		:invoice_interval => [ 'inv_12', 'inv_6', 'inv_3', 'inv_m', ],
		:salutation				=>	[ nil, 'Frau', 'Herr', ],
		:status						=>	[ nil, 'is_open', 'is_due', 'is_paid', 'is_trash'],
	}
	EVENTS = [ :ajax_collect_garbage, :ajax_create_item, :ajax_debitor,
    :ajax_delete_autoinvoice, :ajax_delete_item, :ajax_item,
    :ajax_invoice, :ajax_invoices, :ajax_status, :autoinvoice,
    :create_autoinvoice, :create_debitor, :create_invoice, :debitor,
    :debitors, :generate_invoice, :invoice, :invoices, :login, :logout,
    :pdf, :send_invoice, :sort, :update ]
	STRINGS = [ :name, :contact, :contact_firstname, :contact_title,
    :description, :location, :reminder_body, :reminder_subject,
    :sortvalue, :text, :unit ]
  NUMERIC = [ :unique_id, :hosting_price, :index, :precision, :price,
    :quantity ]
	#future_dates :hosting_invoice_date
	def address_lines(value)
		validate_string(value).split(/\r|\n|\r\n/)
	end
	def phone(value)
		str = value.to_s.strip
		return if(str.empty?)
		if(/^00[0-9 ]{10,}$/.match(str))
			str
		else
			raise SBSM::InvalidDataError.new(:e_invalid_phone, :phone, str)
		end
	end
	def validate_numeric(key, value)
		if(match = /\d*(\.\d{1,2})?/.match(value))
			if(match[1])
				match[0].to_f
			else
				match[0].to_i
			end
		else
			raise SBSM::InvalidDataError.new(:e_invalid_numeric_format, key, value)
		end
	end
end
		end
	end
end
