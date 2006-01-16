#!/usr/bin/env ruby
# Html::View::Debitor -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'view/template'
require 'view/invoices'
require 'htmlgrid/inputtext'
require 'htmlgrid/inputdate'
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
		[0,3]	=> :contact, 
		[0,4]	=> :address_lines,
		[0,5]	=> :location,
		[0,6]	=> :email, 
		[1,7]	=> :submit, 
	}
	FORM_ID = 'debitor'
	EVENT = :update
	SYMBOL_MAP = {
		:address_lines						=>	Textarea,
		:hosting_invoice_interval	=>	HtmlGrid::Select,
		:unique_id								=>	HtmlGrid::Value,
		:hosting_invoice_date			=>	HtmlGrid::InputDate,
	}
	def debitor_type(model)
		select = HtmlGrid::Select.new(:debitor_type, model, @session, self)
		script = "reload_form('#{FORM_ID}', 'ajax_debitor');"
		select.set_attribute('onChange', script)
		select
	end
end
class HostingDebitorForm < DebitorForm
	COMPONENTS = {
		[0,0]		=>	:unique_id,
		[0,1]		=>	:debitor_type,
		[0,2]		=>	:name,	
		[0,3]		=>	:contact,	
		[0,4]		=>	:address_lines,
		[0,5]		=>	:location,
		[0,6]		=>	:email,	
		[0,7]		=>	:hosting_price,
		[0,8]		=>	:hosting_invoice_interval,
		[0,9]	=>	:hosting_invoice_date,
		[1,10]	=>	:submit,	
	}
end
class DebitorComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:form,
		[0,1]	=>	'invoices',
		[0,2]	=>	:invoices,
	}
	CSS_MAP = {
		1	=>	'list-label',
	}
	def form(model)
		Debitor.select_form(model).new(model, @session, self)
	end
	def invoices(model)
		InvoiceList.new(model.invoices, @session, self)
	end
end
class Debitor < Template
	CONTENT = DebitorComposite
	def Debitor.select_form(model)
		case model.debitor_type
		when 'dt_hosting'
			HostingDebitorForm
		else
			DebitorForm
		end
	end
end
		end
	end
end
