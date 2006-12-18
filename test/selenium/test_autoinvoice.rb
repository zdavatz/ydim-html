#!/usr/bin/env ruby
# Html::Selenium::TestAutoInvoice -- de.oddb.org -- 15.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'ostruct'
require 'selenium/unit'
require 'ydim/debitor'
require 'ydim/invoice'

module YDIM
  module Html
    module Selenium
class TestAutoInvoice < Test::Unit::TestCase
  include Selenium::TestCase
  def test_create_autoinvoice
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_autoinvoice"
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
    assert_equal "", get_value("//input[@name='date']")

    assert is_element_present("//select[@name='currency']")
    assert_equal "Währung", get_text("//label[@for='currency']")

    assert is_element_present("//input[@name='precision']")
    assert_equal "text", get_attribute("//input[@name='precision']@type")
    assert_equal "Kommastellen", get_text("//label[@for='precision']")
    assert_equal "2", get_value("//input[@name='precision']")

    assert is_element_present("//select[@name='invoice_interval']")
    assert_equal "inv_12", 
      get_value("//select[@name='invoice_interval']")
    assert_equal "Rechnungs-Intervall", 
      get_text("//label[@for='invoice_interval']")

    assert is_element_present("update")
    assert !is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")
    assert !is_element_present("generate_invoice")
  end
  def test_create_autoinvoice__fail
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_autoinvoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "update"
    wait_for_page_to_load "30000"

    assert is_text_present('Bitte geben Sie das Feld "Beschreibung" an.')
    assert is_element_present("update")
    assert !is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")
    assert !is_element_present("generate_invoice")
  end
  def test_create_autoinvoice__succeed
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_autoinvoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    type "description", "Newly created AutoInvoice"

    invoice = nil
    session.should_receive(:create_autoinvoice).and_return { 
      invoice = AutoInvoice.new(10001)
      invoice.debitor = debitor
      flexstub(invoice).should_receive(:odba_store)
      invoice
    }

    click "update"
    wait_for_page_to_load "30000"

    assert_equal("Newly created AutoInvoice", invoice.description)
    assert_nil(invoice.date)
    assert_equal("CHF", invoice.currency)
    assert_equal(2, invoice.precision)
    assert_equal("inv_12", invoice.invoice_interval)

    assert !is_text_present('Bitte geben Sie das Feld "Beschreibung" an.')
    assert is_element_present("update")
    assert is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")
    assert !is_element_present("generate_invoice")
    assert !is_element_present("reminder_subject")
    assert !is_element_present("reminder_body")

    assert_equal "Newly created AutoInvoice", 
      get_value("//input[@name='description']")

    item = nil
    session.should_receive(:add_items).and_return { |invoice_id, items, invoice_key|
      assert_equal(10001, invoice_id)
      assert_equal(:autoinvoice, invoice_key)
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
    wait_for_condition "selenium.isElementPresent('text[0]');", "10000"
    assert is_element_present("quantity[0]")
    assert is_element_present("unit[0]")
    assert is_element_present("price[0]")
    assert_equal "0.00", get_text("total_netto0")

    session.should_receive(:update_item).and_return { |invoice_id, item_index, data, invoice_key|
      assert_equal(10001, invoice_id)
      assert_equal(0, item_index)
      assert_equal(:autoinvoice, invoice_key)
      data.each { |key, val|
        item.send("#{key}=", val)
      }
      item
    }

    type "text[0]", "Item 1"
    type "quantity[0]", "2"
    type "unit[0]", "pieces"
    type "price[0]", "3.25"
    sleep 0.2
    assert_equal "6.50", get_text("total_netto0")

    click "update"
    wait_for_page_to_load "30000"

    assert is_text_present("Total Netto")
    assert is_text_present("MwSt. (7.6%)")
    assert is_text_present("Total Brutto")

    assert is_element_present("update")
    assert is_element_present("create_item")
    assert !is_element_present("pdf")
    assert !is_element_present("send_invoice")
    assert is_element_present("generate_invoice")
    assert is_element_present("reminder_subject")
    assert is_element_present("reminder_body")

    assert_equal "<invoice>\n2.00 * Item 1: 6.50 exkl. MwSt.\n</invoice>", 
      get_text("reminder_body")

    click "link=debitor@ywesee.com"
    wait_for_page_to_load "30000"
    assert is_text_present("Newly created AutoInvoice")
  end
  def test_generate
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    invoice = YDIM::AutoInvoice.new(10001)
    invoice.debitor = debitor
    invoice.description = 'AutoInvoice'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)

    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    session.should_receive(:autoinvoice).and_return(invoice)
    session.should_receive(:generate_invoice).and_return(invoice)
    session.should_ignore_missing
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "link=AutoInvoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    
    click "generate_invoice"
    wait_for_page_to_load "30000"
    assert is_element_present("update")
    assert is_element_present("create_item")
    assert is_element_present("pdf")
    assert is_element_present("send_invoice")
    assert !is_element_present("generate_invoice")
  end
  def test_precision
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    invoice = YDIM::AutoInvoice.new(10001)
    invoice.debitor = debitor
    invoice.description = 'AutoInvoice'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '3.25', 
                          :quantity => 2)
    invoice.add_item(item)

    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    session.should_receive(:autoinvoice).and_return(invoice)
    session.should_receive(:generate_invoice).and_return(invoice)
    session.should_ignore_missing
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "link=AutoInvoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    
    type "precision", "3"
    wait_for_condition "selenium.isTextPresent('6.500')", "10000"
    assert_equal "6.500", get_text("total_netto0")
  end
  def test_reminder
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    invoice = YDIM::AutoInvoice.new(10001)
    invoice.debitor = debitor
    invoice.description = 'AutoInvoice'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)

    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    session.should_receive(:autoinvoice).and_return(invoice)
    session.should_receive(:generate_invoice).and_return(invoice)
    session.should_ignore_missing
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "link=AutoInvoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Es wird kein Erinnerungsmail versendet")
    
    type "reminder_subject", "Reminder for Invoice"
    type "reminder_body", "Reminder-Text \n<invoice></invoice>\nThanks."
    click "update"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Es wird kein Erinnerungsmail versendet")

    type "date", "1.12.2006"
    click "update"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Wird am 01.11.2006 versendet")
  end
end
    end
  end
end
