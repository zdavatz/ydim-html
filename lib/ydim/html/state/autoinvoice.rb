#!/usr/bin/env ruby
# encoding: utf-8
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
    lnf = @session.lookandfeel
    total = lnf.lookup(:total_netto)
    item_widths = [total.length]
    qty_widths = []
    float = false
    @model.items.each do |item|
      item_widths.push item.text.length
      qty = item.quantity
      qty_widths.push qty.to_i.to_s.length
      float ||= (qty.to_i != qty.to_f)
    end
    item_width = item_widths.max.to_i.next
    qty_width = qty_widths.max.to_i
    total_width = ("%3.2f" % @model.total_netto).length
    fmt = if float
            qty_width += 3
            "%#{qty_width}.2f x %-#{item_width}s %s %#{total_width}.2f\n"
          else
            "%#{qty_width}i x %-#{item_width}s %s %#{total_width}.2f\n"
          end
    invoice = "<invoice>\n"
    currency = @model.currency
    @model.items.each { |item|
      invoice << sprintf(fmt, item.quantity.to_f, item.text,
                         currency, item.total_netto)
    }
    fmt = "%#{qty_width + 2}s %-#{item_width}s %s %#{total_width}.2f\n"
    invoice << sprintf(fmt, '', total,
                       currency, @model.total_netto)
    invoice << "</invoice>"
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
