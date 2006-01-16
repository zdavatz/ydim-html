#!/usr/bin/env ruby
# Html::State::Debitor -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/invoices'
require 'view/debitor'

module YDIM
	module Html
		module State
class AjaxDebitor < SBSM::State
	VOLATILE = true
	def init
		@default_view = Html::View::Debitor.select_form(@model)
	end
end
class Debitor < Global
	include AjaxInvoiceMethods
	VIEW = Html::View::Debitor
	def ajax_debitor
		keys = [ :address_lines, :contact, :debitor_type, :email,
			:hosting_invoice_date, :hosting_invoice_interval, :hosting_price,
			:location, :name ]
		update_model(user_input(keys))
		AjaxDebitor.new(@session, @model)
	end
	def ajax_invoices
		super(@model.invoices)
	end
	def update
		mandatory = [ :name, :contact, :location, :email, :debitor_type ]
		case @session.user_input(:debitor_type)
		when 'dt_hosting'
			mandatory.push(:hosting_price, :hosting_invoice_interval,
										 :hosting_invoice_date)
		end
		keys = mandatory.dup.push(:address_lines)
		input = user_input(keys, mandatory)
		unless(error?)
			puts @model.unique_id
			unless(@model.unique_id)
				@model = @session.create_debitor
			end
			update_model(input)
		end
		self
	end
	private
	def update_model(input)
		input.each { |key, val|
			@model.send("#{key}=".to_sym, val)
		}
		@model.odba_store if(@model.unique_id)
	end
end
		end
	end
end
