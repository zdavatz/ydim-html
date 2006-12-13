#!/usr/bin/env ruby
# Html::State::AutoInvoice -- ydim -- 13.12.2006 -- hwyss@ywesee.com

require 'state/invoice'
require 'view/autoinvoice'

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
    [:description, :date, :currency, :invoice_interval]
  end
end
class CreateAutoInvoice < CreateInvoice
  include AutoInvoiceKeys
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
  def generate_invoice
    _do_update
    if((id = @session.user_input(:unique_id)) \
       && @model.unique_id == id.to_i)
      Invoice.new(@session, @session.generate_invoice(id))
    end
  end
end
    end
  end
end
