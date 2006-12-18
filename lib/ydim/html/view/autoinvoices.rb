#!/usr/bin/env ruby
# Html::View::AutoInvoices -- de.oddb.org -- 13.12.2006 -- hwyss@ywesee.com

require 'ydim/html/view/invoices'

module YDIM
  module Html
    module View
class AutoInvoiceList < InvoiceList
  COMPONENTS = {
    [0,0]  =>  :unique_id,
    [1,0]  =>  :name,
    [2,0]  =>  :email,
    [3,0]  =>  :description,
    [4,0]  =>  :formatted_date,
    [5,0]  =>  :total_netto,
    [6,0]  =>  :total_brutto,
    [7,0]  =>  :currency,
    [8,0]  =>  :generate_invoice,
    [9,0]  =>  :delete,
  }
  CSS_ID = 'autoinvoices'
  links :autoinvoice, :date, :unique_id, :description
  def delete(model)
    link = HtmlGrid::Link.new(:delete, model, @session, self)
    url = @lookandfeel._event_url(:ajax_delete_autoinvoice,
                                 [:unique_id, model.unique_id])
    link.href = sprintf("javascript: reload_list('%s', '%s')", 
                        css_id, url)
    link
  end
  def generate_invoice(model)
    link = HtmlGrid::Link.new(:generate_invoice, model, @session, self)
    link.href = @lookandfeel._event_url(:generate_invoice, 
                                        {:unique_id => model.unique_id})
    link
  end
end
    end
  end
end
