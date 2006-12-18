#!/usr/bin/env ruby
# Html::State::Invoice -- ydim -- 16.01.2006 -- hwyss@ywesee.com

require 'ydim/html/state/global_predefine'
require 'ydim/html/state/ajax_values'
require 'ydim/html/state/confirm'
require 'ydim/html/view/invoice'

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
module InvoiceKeys
  def invoice_key
    :invoice
  end
  def invoice_keys
    invoice_mandatory + [:precision]
  end
  def invoice_mandatory
    [:description, :date, :currency]
  end
end
class CreateInvoice < Global
  include InvoiceKeys
	VIEW = Html::View::Invoice
	attr_reader :model
  def update
    _update(Invoice)
  end
	def _update(nextclass)
		input = user_input(invoice_keys, invoice_mandatory)
		input[:precision] = (input[:precision] || 2).to_i
		unless(error?)
			@model = @session.send("create_#{invoice_key}",
                             @model.debitor.unique_id)
			input.each { |key, val|
				@model.send("#{key}=", val)
			}
			@model.odba_store
			nextclass.new(@session, @model)
		end
	end
end
class Invoice < Global
  include InvoiceKeys
	VIEW = Html::View::Invoice
	attr_reader :model
	def ajax_create_item
		if(id = @session.user_input(:unique_id))
			begin
				@session.add_items(id.to_i, [{:time => Time.now}], invoice_key)
			rescue IndexError
			end
		end
		AjaxItems.new(@session, @model.items)
	end
	def ajax_delete_item
		if((id = @session.user_input(:unique_id)) \
			&& (idx = @session.user_input(:index)))
			begin
				@session.delete_item(id.to_i, idx.to_i, invoice_key)
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
				item = @session.update_item(id.to_i, idx.to_i, input, 
                                    invoice_key)
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
    _do_update
    super
  end
	def update
		_do_update
		self
	end
	def _do_update
		if((id = @session.user_input(:unique_id)) \
       && @model.unique_id == id.to_i)
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
				@session.update_item(id.to_i, idx.to_i, item, invoice_key)
			}

			_do_update_invoice(user_input(invoice_keys, invoice_mandatory))
			@model.odba_store
		end
	end
  def _do_update_invoice(input)
    input[:precision] = (input[:precision] || 2).to_i
    input.each { |key, val|
      @model.send("#{key}=", val)
    }
  end
end
		end
	end
end
