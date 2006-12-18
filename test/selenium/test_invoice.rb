#!/usr/bin/env ruby
# Html::Selenium::TestInvoice -- ydim -- 15.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'ostruct'
require 'selenium/unit'
require 'ydim/debitor'
require 'ydim/invoice'

module YDIM
  module Html
    module Selenium
class TestInvoice < Test::Unit::TestCase
  include Selenium::TestCase
  def setup_debitor
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    debitor
  end
  def test_create_invoice
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    assert_equal "YDIM", get_title
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_invoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert_equal "ID", get_text("//label[@for='unique_id']")

    url = "http://localhost:10080/de/debitor/unique_id/1"
    assert_equal url, get_attribute("//a[@name='name']@href")
    assert_equal url, get_attribute("//a[@name='email']@href")
    assert_equal "Foo", get_text("//a[@name='name']")
    assert_equal "debitor@ywesee.com", get_text("//a[@name='email']")
    
    assert is_element_present("//input[@name='description']")
    assert_equal "text", 
      get_attribute("//input[@name='description']@type")
    assert_equal "Beschreibung", get_text("//label[@for='description']")
    
    assert is_element_present("//input[@name='date']")
    assert_equal "text", get_attribute("//input[@name='date']@type")
    assert_equal "Rechnungsdatum", get_text("//label[@for='date']")
    assert_equal Date.today.strftime('%d.%m.%Y'), 
      get_value("//input[@name='date']")

    assert is_element_present("//select[@name='currency']")
    assert_equal "Währung", get_text("//label[@for='currency']")

    assert is_element_present("//input[@name='precision']")
    assert_equal "text", get_attribute("//input[@name='precision']@type")
    assert_equal "Kommastellen", get_text("//label[@for='precision']")
    assert_equal "2", get_value("//input[@name='precision']")

    assert is_element_present("update")
    assert !is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")
  end
  def test_create_invoice__fail
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    assert_equal "YDIM", get_title
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_invoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "update"
    wait_for_page_to_load "30000"

    assert is_text_present('Bitte geben Sie das Feld "Beschreibung" an.')
    assert is_element_present("update")
    assert !is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")
  end
  def test_create_invoice__succeed
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    assert_equal "YDIM", get_title
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_invoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    type "description", "Newly created Invoice"

    invoice = nil
    session.should_receive(:create_invoice).and_return { 
      invoice = Invoice.new(10001)
      invoice.debitor = debitor
      flexstub(invoice).should_receive(:odba_store)
      invoice
    }

    click "update"
    wait_for_page_to_load "30000"

    assert_equal("Newly created Invoice", invoice.description)
    assert_equal(Date.today, invoice.date)
    assert_equal("CHF", invoice.currency)
    assert_equal(2, invoice.precision)

    assert !is_text_present('Bitte geben Sie das Feld "Beschreibung" an.')
    assert is_element_present("update")
    assert is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")

    assert_equal "Newly created Invoice", 
      get_value("//input[@name='description']")

    item = nil
    session.should_receive(:add_items).and_return { |invoice_id, items, invoice_key|
      assert_equal(10001, invoice_id)
      assert_equal(:invoice, invoice_key)
      assert_equal(1, items.size)
      hash = items.first
      assert_instance_of(Hash, hash)
      assert_equal(1, hash.size)
      assert_instance_of(Time, hash[:time])
      item = YDIM::Item.new(hash)
      item.index = 0
      invoice.items.push(item)
      item
    }
    click "create_item"
    ## waitForElementPresent:
    assert !60.times { 
      break if (is_element_present("text[0]") rescue false)
      sleep 1 
    }
    assert is_element_present("quantity[0]")
    assert is_element_present("unit[0]")
    assert is_element_present("price[0]")
    assert_equal "0.00", get_text("total_netto0")

    assert is_element_present("update")
    assert is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")

    session.should_receive(:update_item).and_return { |invoice_id, item_index, data, invoice_key|
      assert_equal(10001, invoice_id)
      assert_equal(0, item_index)
      assert_equal(:invoice, invoice_key)
      data.each { |key, val|
        item.send("#{key}=", val)
      }
      item
    }

    type "text[0]", "Item 1"
    type "quantity[0]", "2"
    type "unit[0]", "pieces"
    type "price[0]", "3.25"
    sleep 0.1
    assert_equal "6.50", get_text("total_netto0")
    
    assert is_element_present("update")
    assert is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")

    click "update"
    wait_for_page_to_load "30000"

    assert is_text_present("Total Netto")
    assert is_text_present("MwSt. (7.6%)")
    assert is_text_present("Total Brutto")

    assert is_element_present("update")
    assert is_element_present("create_item")
    assert is_element_present("pdf")
    assert is_element_present("send_invoice")

    click "link=debitor@ywesee.com"
    wait_for_page_to_load "30000"
    assert is_text_present("Newly created Invoice")
  end
  def test_delete_item
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    invoice = YDIM::Invoice.new(10001)
    invoice.debitor = debitor
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)
    session.should_receive(:invoice).and_return(invoice)

    assert_equal "YDIM", get_title
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "link=10001"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present('text[0]')
    assert_equal "Item", get_value('text[0]')

    session.should_receive(:delete_item).with(10001, 0, :invoice).and_return { 
      invoice.items.delete(item)
    }

    click "link=Löschen"
    wait_for_condition "!selenium.isElementPresent('text[0]')", "10000"
    assert !is_element_present('text[0]')
  end
  def test_currency
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    invoice = YDIM::Invoice.new(10001)
    invoice.debitor = debitor
    invoice.currency = 'CHF'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)
    session.should_receive(:invoice).and_return(invoice)

    assert_equal "YDIM", get_title
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "link=10001"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present('text[0]')
    assert_equal "Item", get_value('text[0]')

    session.should_receive(:update_item).and_return { 
      item.price = 66
    }

    select "currency", "label=EUR"
    wait_for_condition "!selenium.isTextPresent('500.00')", "10000"
    assert is_text_present('330.00')
  end
  def test_mail
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    invoice = YDIM::Invoice.new(10001)
    invoice.debitor = debitor
    invoice.currency = 'CHF'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)
    session.should_receive(:invoice).and_return(invoice)

    assert_equal "YDIM", get_title
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "link=10001"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present('send_invoice')

    session.should_receive(:update_item)
    session.should_receive(:send_invoice).times(1).and_return { 
      ['customer@ywesee.com', 'admin@ywesee.com']
    }
    click "send_invoice"
    wait_for_page_to_load "30000"
    assert is_text_present("Die Rechnung wurde an folgende Email-Adressen verschickt: customer@ywesee.com, admin@ywesee.com")

  end
end
    end
  end
end
