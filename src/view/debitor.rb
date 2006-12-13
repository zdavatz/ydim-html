#!/usr/bin/env ruby
# Html::View::Debitor -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'view/template'
require 'view/autoinvoices'
require 'view/invoices'
require 'htmlgrid/inputtext'
require 'htmlgrid/inputdate'
require 'htmlgrid/labeltext'
require 'htmlgrid/select'
require 'htmlgrid/textarea'

module YDIM
	module Html
		module View
class Textarea < HtmlGrid::Textarea
	LABEL = true
end
class DebitorForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]	=> :unique_id,
		[0,1]	=> :debitor_type,
		[0,2]	=> :name, 
		[0,3]	=> :salutation, 
		[0,4]	=> :contact, 
		[0,5]	=> :contact_firstname, 
		[0,6]	=> :contact_title, 
		[0,7]	=> :address_lines,
		[0,8]	=> :location,
		[0,9]	=> :email, 
		[0,10]	=>	:phone,	
		[1,11]	=> :submit, 
	}
	FORM_ID = 'debitor'
	EVENT = :update
	SYMBOL_MAP = {
		:unique_id								=>	HtmlGrid::Value,
		:salutation								=>	HtmlGrid::Select,
	}
	def debitor_type(model)
		select = HtmlGrid::Select.new(:debitor_type, model, @session, self)
		script = "reload_form('#{FORM_ID}', 'ajax_debitor');"
		select.set_attribute('onChange', script)
		select
	end
	def generate_invoice(model)
		button = HtmlGrid::Button.new(:generate_invoice, model, @session, self)
		url = @lookandfeel._event_url(:generate_invoice, 
																	{:unique_id, model.unique_id})
		button.set_attribute('onClick', "document.location.href='#{url}'")
		button
	end
	def hidden_fields(context)
		super << context.hidden('unique_id', @model.unique_id)
	end
end
class DebitorComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:form,
		[0,1]	=>	:is_open,
		[1,1]	=>	:is_due,
		[2,1]	=>	:is_paid,
		[3,1]	=>	:is_trash,
		[0,2]	=>	:invoices,
		[0,3]	=>	:invoice_list,
		[0,4]	=>	:create_invoice,
		[0,5]	=>	:autoinvoices,
		[0,6]	=>	:autoinvoice_list,
		[0,7]	=>	:create_autoinvoice,
	}
	CSS_MAP = {
		1	=>	'subnavigation',
		2	=>	'padded',
		4	=>	'padded',
		5	=>	'padded',
		7	=>	'padded',
	}
	SYMBOL_MAP = {
		:invoices	    =>	HtmlGrid::LabelText,
		:autoinvoices	=>	HtmlGrid::LabelText,
	}
  def autoinvoice_list(model)
    AutoInvoiceList.new(@session.state.autoinvoice_infos, @session, self)
  end
  def button(key, model)
  	if(model.unique_id)
  		button = HtmlGrid::Button.new(key, model, @session, self)
  		args = {:unique_id => model.unique_id}
  		url = @lookandfeel._event_url(key, args)
  		button.set_attribute('onClick', "document.location.href='#{url}'")
  		button
  	end
  end
  def create_autoinvoice(model)
    button(:create_autoinvoice, model)
  end
  def create_invoice(model)
    button(:create_invoice, model)
  end
	def form(model)
		Debitor.select_form(model).new(model, @session, self)
	end
	def invoice_list(model)
		InvoiceList.new(@session.state.invoice_infos, @session, self)
	end
end
class Debitor < Template
	CONTENT = DebitorComposite
	def Debitor.select_form(model)
		DebitorForm
	end
	def subnavigation(model)
		InvoicesSubnavigation.new(model, @session, self)
	end
end
		end
	end
end
