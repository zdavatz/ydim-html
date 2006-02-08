#!/usr/bin/env ruby
# Html::State::Invoice -- ydim -- 16.01.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/ajax_values'
require 'state/confirm'
require 'view/invoice'

module YDIM
	module Html
		module State
class AjaxItems < SBSM::State
	VOLATILE = true
	VIEW = Html::View::ItemList
end
class AjaxInvoice < SBSM::State
	VOLATILE = true
	VIEW = Html::View::InvoiceComposite
end
class CreateInvoice < Global
	VIEW = Html::View::Invoice
	attr_reader :model
	def update
		keys = [:description, :date, :currency]
		input = user_input(keys, keys)
		unless(error?)
			@model = @session.create_invoice(@model.debitor.unique_id)
			input.each { |key, val|
				@model.send("#{key}=", val)
			}
			@model.odba_store
			Invoice.new(@session, @model)
		end
	end
end
class Invoice < Global
	VIEW = Html::View::Invoice
	attr_reader :model
	def ajax_create_item
		if(id = @session.user_input(:unique_id))
			begin
				@session.add_items(id.to_i, [{:time => Time.now}])
			rescue IndexError
			end
		end
		AjaxItems.new(@session, @model.items)
	end
	def ajax_delete_item
		if((id = @session.user_input(:unique_id)) \
			&& (idx = @session.user_input(:index)))
			begin
				@session.delete_item(id.to_i, idx.to_i)
			rescue IndexError
			end
		end
		AjaxItems.new(@session, @model.items)
	end
	def ajax_item
		data = {}
		if((id = @session.user_input(:unique_id)) \
			&& (idx = @session.user_input(:index)))
			begin
				keys = [:text, :quantity, :unit, :price]
				input = user_input(keys).delete_if { |key, val| val.nil?  }
				item = @session.update_item(id.to_i, idx.to_i, input)
				input.each { |key, val| data.store("#{key}[#{item.index}]", val) }
				data.store("total_netto#{item.index}", item.total_netto)
			rescue IndexError
			end
		end
		[:total_netto, :vat, :total_brutto].each { |key|
			data.store(key, @model.send(key))
		}
		AjaxValues.new(@session, data)
	end
	def ajax_invoice
		_do_update
		AjaxInvoice.new(@session, @model)
	end
	def send_invoice
		if(id = @session.user_input(:unique_id))
			recipients = @session.send_invoice(id.to_i)
			message = @session.lookandfeel.lookup(:confirm_send_invoice, 
																						recipients.join(', '))
			Html::State::Confirm.new(@session, message)
		end
	end
	def update
		_do_update
		self
	end
	def _do_update
		if((id = @session.user_input(:unique_id)) && @model.unique_id == id.to_i)
			## update items
			keys = [:text, :quantity, :unit, :price]
			data = {}
			user_input(keys).each { |key, hash|
				hash.each { |idx, value|
					(data[idx] ||= {}).store(key, value)
				} unless hash.nil?
			}
			target = origin = nil
			converter = if((target = @session.user_input(:currency)) \
				 && (origin = @model.currency) \
				 && origin != target)
				@session.currency_converter
			end
			data.each { |idx, item|
				if(converter)
					item[:price] = converter.convert(item[:price], origin, target)
				end
				@session.update_item(id.to_i, idx.to_i, item)
			}

			## update invoice
			keys = [:description, :date, :currency, :precision]
			input = user_input(keys, keys)
			input[:precision] = input[:precision].to_i
			puts input.inspect
			input.each { |key, val|
				@model.send("#{key}=", val)
			}
			@model.odba_store
		end
	end
end
		end
	end
end
