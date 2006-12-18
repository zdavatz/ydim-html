#!/usr/bin/env ruby
# Html::State::AutoInvoice -- ydim -- 13.12.2006 -- hwyss@ywesee.com

require 'ydim/html/state/invoice'
require 'ydim/html/view/autoinvoice'

module YDIM
  module Html
    module State
class AjaxAutoInvoice < SBSM::State
  VOLATILE = true
  VIEW = Html::View::AutoInvoiceComposite
end
module AutoInvoiceKeys
  def invoice_key
    :autoinvoice
  end
  def invoice_keys
    super + [ :date, :reminder_body, :reminder_subject ]
  end
  def invoice_mandatory
    [ :description, :currency, :invoice_interval ]
  end
end
class CreateAutoInvoice < CreateInvoice
  include AutoInvoiceKeys
  VIEW = Html::View::AutoInvoice
  def update
    _update(AutoInvoice)
  end
end
class AutoInvoice < Invoice
  include AutoInvoiceKeys
  VIEW = Html::View::AutoInvoice
  def ajax_invoice
    _do_update
    AjaxAutoInvoice.new(@session, @model)
  end
  def format_invoice
    @model.items.collect { |item|
      sprintf(@session.lookandfeel.lookup(:reminder_format), 
             item.quantity.to_f, item.text, item.total_netto)
    }.join("\n")
  end
  def generate_invoice
    _do_update
    if((id = @session.user_input(:unique_id)) \
       && @model.unique_id == id.to_i)
      Invoice.new(@session, @session.generate_invoice(id))
    end
  end
  def _do_update_invoice(input)
    ptrn = %r{<invoice>.*</invoice>}m
    if(body = input[:reminder_body])
      test = body.gsub(ptrn, "").strip
      if(test.empty?)
        input.store(:reminder_body, nil)
      else
        input.store(:reminder_body, body.gsub(ptrn, format_invoice))
      end
    end
    super(input)
  end
end
    end
  end
end
