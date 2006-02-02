#!/usr/bin/env ruby
# Html::View::Debitor -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'view/template'
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
		[0,5]	=> :address_lines,
		[0,6]	=> :location,
		[0,7]	=> :email, 
		[1,8]	=> :submit, 
	}
	FORM_ID = 'debitor'
	EVENT = :update
	SYMBOL_MAP = {
		:hosting_invoice_interval	=>	HtmlGrid::Select,
		:hosting_items						=>	HtmlGrid::LabelText,	
		:unique_id								=>	HtmlGrid::Value,
		:hosting_invoice_date			=>	HtmlGrid::InputDate,
		:salutation								=>	HtmlGrid::Select,
	}
	def debitor_type(model)
		select = HtmlGrid::Select.new(:debitor_type, model, @session, self)
		script = "reload_form('#{FORM_ID}', 'ajax_debitor');"
		select.set_attribute('onChange', script)
		select
	end
	def hidden_fields(context)
		super << context.hidden('unique_id', @model.unique_id)
	end
end
class HostingItemList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:text,
		[1,0]	=>	:price,
		[2,0]	=>	:delete,
	}
	CSS_ID = 'hosting-items'
	CSS_MAP = {
		[2,0]	=>	'right',
	}
	COMPONENT_CSS_MAP = {
		[1,0]	=>	'small'
	}
	DEFAULT_CLASS = HtmlGrid::InputText
	LOOKANDFEEL_MAP = {
		:price	=>	:hosting_price,
		:text		=>	:domain,
	}
	SORT_DEFAULT = nil
	ajax_inputs :text, :price
	def compose_footer(offset)
		link = HtmlGrid::Button.new(:create_hosting_item, @model, @session, self)
		args = { :unique_id => @session.state.model.unique_id }
		url = @lookandfeel.event_url(:ajax_create_item, args)
		link.set_attribute('onClick', "reload_list('hosting-items', '#{url}');")
		@grid.add(link, *offset)
	end
	def delete(model)
		link = HtmlGrid::Link.new(:delete, model, @session, self)
		args = {
			:unique_id	=>	@session.state.model.unique_id,
			:index			=>	model.index,
		}
		url = @lookandfeel.event_url(:ajax_delete_item, args)
		link.href = "javascript: reload_list('hosting-items', '#{url}')"
		link
	end
end
class HostingDebitorForm < DebitorForm
	COMPONENTS = {
		[0,0]		=>	:unique_id,
		[0,1]		=>	:debitor_type,
		[0,2]		=>	:name,	
		[0,3]		=>	:salutation, 
		[0,4]		=>	:contact,	
		[0,5]		=>	:address_lines,
		[0,6]		=>	:location,
		[0,7]		=>	:email,	
		[0,8]		=>	:hosting_price,
		[1,9]		=>	:hosting_item_list,
		[0,10]	=>	:hosting_invoice_interval,
		[0,11]	=>	:hosting_invoice_date,
		[1,12]	=>	:submit,	
	}
	CSS_MAP = {
		[1,9]	=>	'unpadded',
	}
	def hosting_item_list(model)
		if(model.unique_id)
			HostingItemList.new(model.hosting_items || [], @session, self)
		end
	end
end
class DebitorComposite < HtmlGrid::DivComposite
	COMPONENTS = {
		[0,0]	=>	:form,
		[0,1]	=>	:ps_open,
		[1,1]	=>	:ps_due,
		[2,1]	=>	:ps_paid,
		[0,2]	=>	:invoices,
		[0,3]	=>	:invoice_list,
		[0,4]	=>	:create_invoice,
	}
	CSS_MAP = {
		1	=>	'subnavigation',
		2	=>	'padded',
		4	=>	'padded',
	}
	SYMBOL_MAP = {
		:invoices	=>	HtmlGrid::LabelText,
	}
	def create_invoice(model)
		if(model.unique_id)
			button = HtmlGrid::Button.new(:create_invoice, model, @session, self)
			args = {:unique_id => model.unique_id}
			url = @lookandfeel._event_url(:create_invoice, args)
			button.set_attribute('onClick', "document.location.href='#{url}'")
			button
		end
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
		case model.debitor_type
		when 'dt_hosting'
			HostingDebitorForm
		else
			DebitorForm
		end
	end
	def subnavigation(model)
		InvoicesSubnavigation.new(model, @session, self)
	end
end
		end
	end
end
