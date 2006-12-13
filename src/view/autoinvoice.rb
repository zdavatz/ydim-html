#!/usr/bin/env ruby
# Html::View::AutoInvoice -- ydim -- 13.12.2006 -- hwyss@ywesee.com

require 'view/invoice'

module YDIM
  module Html
    module View
class AutoInvoiceInnerComposite < InvoiceInnerComposite
	COMPONENTS = {
		[0,0]		=>	:unique_id,
		[0,1,0]	=>	:debitor_name,
		[1,1,1]	=>	'dash', 
		[1,1,2]	=>	:debitor_email,
		[0,2]		=>	:description, 
		[0,3]		=>	:date,
		[0,4]		=>	:currency,
		[0,5]		=>	:precision,
		[0,6]		=>	:invoice_interval,
    [0,7]   =>  :reminder_subject,
    [0,8]   =>  :reminder_body,
	}
	COMPONENT_CSS_MAP = {
		[0,2]	=>	'extralarge',
		[0,5]	=>	'small',
		[0,7]	=>	'extralarge',
	}
	CSS_MAP = {
		[0,8]	=>	'top',
	}
  def reminder_body(model)
    input = HtmlGrid::Textarea.new(:reminder_body, model, @session, self)
    input.label = true
    input
  end
end
class AutoInvoiceComposite < InvoiceComposite
	COMPONENTS = {
		[0,0]	=>	AutoInvoiceInnerComposite,
		[0,1]	=>	:items,
		[0,2]	=>	InvoiceTotalComposite,
		[0,3]	=>	:submit,
		[1,3]	=>	:generate_invoice,
	}
  def generate_invoice(model)
    button(:generate_invoice, model)
  end
end
class AutoInvoice < Invoice
	CONTENT = AutoInvoiceComposite
end
    end
  end
end
