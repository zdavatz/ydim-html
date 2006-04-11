#!/usr/bin/env ruby
# Html::State::Debitor -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/ajax_values'
require 'state/invoices'
require 'view/debitor'

module YDIM
	module Html
		module State
class AjaxHostingItems < SBSM::State
	VOLATILE = true
	VIEW = Html::View::HostingItemList
end
class AjaxDebitor < SBSM::State
	VOLATILE = true
	def init
		@default_view = Html::View::Debitor.select_form(@model)
	end
end
class Debitor < Global
	include AjaxInvoiceMethods
	attr_reader :model, :invoice_infos
	VIEW = Html::View::Debitor
	def init
		super
		load_invoices
	end
	def ajax_create_item
		if(id = @session.user_input(:unique_id))
			begin
				@session.create_hosting_item(id.to_i)
			rescue IndexError
			end
		end
		AjaxHostingItems.new(@session, @model.hosting_items)
	end
	def ajax_debitor
		keys = [ :address_lines, :contact, :contact_firstname, :contact_title,
			:debitor_type, :email, :hosting_invoice_date, :hosting_invoice_interval,
			:hosting_price, :location, :name, :salutation, :phone ]
		update_model(user_input(keys))
		AjaxDebitor.new(@session, @model)
	end
	def ajax_delete_item
		if((id = @session.user_input(:unique_id)) \
			&& (idx = @session.user_input(:index)))
			begin
				@session.delete_hosting_item(id.to_i, idx.to_i)
			rescue IndexError
			end
		end
		AjaxHostingItems.new(@session, @model.hosting_items)
	end
	def ajax_invoices
		super(@invoice_infos)
	end
	def ajax_item
		data = {}
		if((id = @session.user_input(:unique_id)) \
			&& (idx = @session.user_input(:index)))
			begin
				keys = [:text, :price]
				input = user_input(keys).delete_if { |key, val| val.nil?  }
				item = @session.update_hosting_item(id.to_i, idx.to_i, input)
				input.each { |key, val| data.store("#{key}[#{item.index}]", val) }
			rescue IndexError
			end
		end
		AjaxValues.new(@session, data)
	end
	def generate_invoice
		if(id = @session.user_input(:unique_id))
			Invoice.new(@session, @session.generate_invoice(id.to_i))
		end
	end
	def update
		mandatory = [ :contact, :debitor_type, :email,
			:location, :name, ]
		defaults = {}
		case @session.user_input(:debitor_type)
		when 'dt_hosting'
			mandatory.push(:hosting_price, :hosting_invoice_interval,
										 :hosting_invoice_date)
			defaults.store(:hosting_invoice_date, Date.today + 1)
			update_hosting_items
		end
		keys = mandatory.dup.push(:address_lines, :contact_firstname,
															:contact_title, :salutation, :phone)
		input = defaults.update(user_input(keys, mandatory))
		unless(error? || @model.unique_id)
			@model = @session.create_debitor
		end
		update_model(input)
		self
	end
	def update_hosting_items
		if((id = @session.user_input(:unique_id)) && @model.unique_id == id.to_i)
			## update items
			keys = [:text, :price]
			data = {}
			user_input(keys).each { |key, hash|
				hash.each { |idx, value|
					(data[idx] ||= {}).store(key, value)
				} unless hash.nil?
			}
			data.each { |idx, item|
				@session.update_hosting_item(id.to_i, idx.to_i, item)
			}
		end
	end
	private
	def load_invoices
		invoices = @model.invoice_infos(@session.user_input(:status) || 'is_open')
		@invoice_infos = sort_invoices(currency_convert(invoices))
	end
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
