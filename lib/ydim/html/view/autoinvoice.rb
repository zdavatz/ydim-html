#!/usr/bin/env ruby
# Html::View::AutoInvoice -- ydim -- 13.12.2006 -- hwyss@ywesee.com

require 'ydim/html/view/invoice'

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
	}
end
class AutoInvoiceReminderComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]   =>  :reminder_subject,
    [0,1]   =>  :reminder_body,
    [1,2]   =>  :reminder_date,
  }
  CSS_MAP = {
    [0,1]  =>  'top',
  }
  COMPONENT_CSS_MAP = {
    [0,0]  =>  'extralarge',
  }
  LABELS = true
  def reminder_body(model)
    input = HtmlGrid::Textarea.new(:reminder_body, model, @session, self)
    input.set_attribute('wrap', 'hard')
    input.set_attribute('cols', '72')
    input.set_attribute('style', 'font-family: fixed;')
    input.label = true
    input.unescaped = true
    value = model.reminder_body
    if(value.nil? || value.empty?)
      input.value = @session.state.format_invoice
    end
    input
  end
  def reminder_date(model)
    body = model.reminder_body.to_s.strip
    subject = model.reminder_subject.to_s.strip
    if(body.empty? || subject.empty? || !model.date)
      @lookandfeel.lookup(:reminder_none)
    else
      (model.date << 1).strftime(@lookandfeel.lookup(:reminder_date))
    end
  end
end
class AutoInvoiceComposite < InvoiceComposite
	COMPONENTS = {
		[0,0]	=>	AutoInvoiceInnerComposite,
		[0,1]	=>	:items,
		[0,2]	=>	InvoiceTotalComposite,
		[0,3]	=>	AutoInvoiceReminderComposite,
		[0,4]	=>	:submit,
		[1,4]	=>	:generate_invoice,
	}
	CSS_MAP = {
		4	=>	'padded'
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
