#!/usr/bin/env ruby
# Selenium::TestDebitors -- ydim -- 14.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'ostruct'
require 'selenium/unit'
require 'ydim/invoice'

module YDIM
  module Html
    module Selenium
class TestDebitor < Test::Unit::TestCase
  include Selenium::TestCase
  def test_create_debitor
    login
    assert_equal "YDIM", get_title
    click "create_debitor"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert_equal "ID", get_text("//label[@for='unique_id']")
    
    assert is_element_present("//select[@name='debitor_type']")
    assert_raises(SeleniumCommandError) {
      get_attribute("//select[@name='debitor_type']@onchange")
    }
    assert_equal "Kundenart", 
      get_text("//label[@for='debitor_type']")
    
    assert is_element_present("//input[@name='name']")
    assert_equal "text", 
      get_attribute("//input[@name='name']@type")
    assert_equal "Firma", 
      get_text("//label[@for='name']")
    
    assert is_element_present("//select[@name='salutation']")
    assert_equal "Anrede", 
      get_text("//label[@for='salutation']")
    
    assert is_element_present("//input[@name='contact']")
    assert_equal "text", 
      get_attribute("//input[@name='contact']@type")
    assert_equal "Name", 
      get_text("//label[@for='contact']")
    
    assert is_element_present("//input[@name='contact_firstname']")
    assert_equal "text", 
      get_attribute("//input[@name='contact_firstname']@type")
    assert_equal "Vorname", 
      get_text("//label[@for='contact_firstname']")
    
    assert is_element_present("//input[@name='contact_title']")
    assert_equal "text", 
      get_attribute("//input[@name='contact_title']@type")
    assert_equal "Titel", 
      get_text("//label[@for='contact_title']")
    
    assert is_element_present("//input[@name='address_lines']")
    assert_equal "text", 
      get_attribute("//input[@name='address_lines']@type")
    assert_equal "Strasse/Nr.", 
      get_text("//label[@for='address_lines']")
    
    assert is_element_present("//input[@name='location']")
    assert_equal "text", 
      get_attribute("//input[@name='location']@type")
    assert_equal "PLZ/Ort", 
      get_text("//label[@for='location']")

    assert is_element_present("//input[@name='email']")
    assert_equal "text", 
      get_attribute("//input[@name='email']@type")
    assert_equal "Email", 
      get_text("//label[@for='email']")
    
    assert is_element_present("//input[@name='phone']")
    assert_equal "text", 
      get_attribute("//input[@name='phone']@type")
    assert_equal "Telefon", 
      get_text("//label[@for='phone']")

    assert is_element_present("update")
    assert !is_element_present("create_invoice")
    assert !is_element_present("create_autoinvoice")
  end
  def test_create_debitor__fail
    login
    assert_equal "YDIM", get_title
    click "create_debitor"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "update"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    assert is_text_present('Bitte geben Sie das Feld "Kundenart" an.')
    assert is_text_present('Bitte geben Sie das Feld "Firma" an.')
    assert is_text_present('Bitte geben Sie das Feld "Name" an.')
    assert is_text_present('Bitte geben Sie das Feld "PLZ/Ort" an.')
    assert is_text_present('Bitte geben Sie das Feld "Email" an.')
    assert !is_element_present("create_invoice")
    assert !is_element_present("create_autoinvoice")
  end
  def test_create_debitor__fail_validated
    login
    assert_equal "YDIM", get_title
    click "create_debitor"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    select "debitor_type", "Apotheke"
    type "name", "Company"
    select "salutation", "Herr"
    type "contact", "Contact"
    type "contact_firstname", "Firstname"
    type "contact_title", "Dr."
    type "address_lines", "Street 45"
    type "location", "8006 Zuerich"
    type "email", "testywesee.com"
    type "phone", "043 540 0549"

    click "update"
    wait_for_page_to_load "30000"

    assert_equal "YDIM", get_title
    assert is_text_present("Die angegebene Email-Adresse ist ungültig.")
    assert is_text_present("Die angegebene Telefonnummer ist ungültig.")
    assert !is_text_present('Bitte geben Sie das Feld "Kundenart" an.')
    assert !is_text_present('Bitte geben Sie das Feld "Firma" an.')
    assert !is_text_present('Bitte geben Sie das Feld "Name" an.')
    assert !is_text_present('Bitte geben Sie das Feld "PLZ/Ort" an.')
    assert !is_text_present('Bitte geben Sie das Feld "Email" an.')
    assert !is_element_present("create_invoice")
    assert !is_element_present("create_autoinvoice")

    assert_equal "Apotheke", get_selected_label("debitor_type")
    assert_equal "Company", get_value("name")
    assert_equal "Herr", get_selected_label("salutation")
    assert_equal "Contact", get_value("contact")
    assert_equal "Firstname", get_value("contact_firstname")
    assert_equal "Dr.", get_value("contact_title")
    assert_equal "Street 45", get_value("address_lines")
    assert_equal "8006 Zuerich", get_value("location")
    assert_equal "testywesee.com", get_value("email")
    assert_equal "043 540 0549", get_value("phone")
  end
  def test_create_debitor__succeed
    session = login
    assert_equal "YDIM", get_title
    click "create_debitor"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    select "debitor_type", "Apotheke"
    type "name", "Company"
    select "salutation", "Herr"
    type "contact", "Contact"
    type "contact_firstname", "Firstname"
    type "contact_title", "Dr."
    type "address_lines", "Street 45"
    type "location", "8006 Zuerich"
    type "email", "test@ywesee.com"
    type "phone", "0041 43 540 0549"

    debitor = OpenStruct.new
    debitor.unique_id = 1
    session.should_receive(:create_debitor).and_return(debitor)
    click "update"
    wait_for_page_to_load "30000"

    assert_equal('dt_pharmacy', debitor.debitor_type)
    assert_equal('Company', debitor.name)
    assert_equal('Herr', debitor.salutation)
    assert_equal('Contact', debitor.contact)
    assert_equal('Firstname', debitor.contact_firstname)
    assert_equal('Dr.', debitor.contact_title)
    assert_equal(['Street 45'], debitor.address_lines)
    assert_equal('8006 Zuerich', debitor.location)
    assert_equal('test@ywesee.com', debitor.email)
    assert_equal('0041 43 540 0549', debitor.phone)

    assert_equal "YDIM", get_title
    assert !is_text_present('Bitte geben Sie das Feld "Kundenart" an.')
    assert !is_text_present('Bitte geben Sie das Feld "Firma" an.')
    assert !is_text_present('Bitte geben Sie das Feld "Name" an.')
    assert !is_text_present('Bitte geben Sie das Feld "PLZ/Ort" an.')
    assert !is_text_present('Bitte geben Sie das Feld "Email" an.')
    assert is_element_present("create_invoice")
    assert is_element_present("create_autoinvoice")

    assert_equal "Apotheke", get_selected_label("debitor_type")
    assert_equal "Company", get_value("name")
    assert_equal "Herr", get_selected_label("salutation")
    assert_equal "Contact", get_value("contact")
    assert_equal "Firstname", get_value("contact_firstname")
    assert_equal "Dr.", get_value("contact_title")
    assert_equal "Street 45", get_value("address_lines")
    assert_equal "8006 Zuerich", get_value("location")
    assert_equal "test@ywesee.com", get_value("email")
    assert_equal "0041 43 540 0549", get_value("phone")
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

    click "link=Generieren"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present("update")
    assert is_element_present("create_item")
    assert is_element_present("pdf")
    assert is_element_present("send_invoice")
    assert !is_element_present("generate_invoice")
  end
  def test_delete_autoinvoice
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
    assert is_text_present("AutoInvoice")

    session.should_receive(:delete_autoinvoice).with(10001).and_return { 
      debitor.delete_autoinvoice(invoice)
    }
    click "link=Löschen"
    wait_for_condition "!selenium.isTextPresent('AutoInvoice')", "10000"
    assert_equal "YDIM", get_title
    assert !is_text_present("AutoInvoice")
  end
  def test_invoices
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    invoice = YDIM::Invoice.new(10001)
    invoice.debitor = debitor
    invoice.description = 'Invoice'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)

    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    session.should_receive(:invoice).and_return(invoice)
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Invoice")

    click "link=offen"
    wait_for_condition "!selenium.isTextPresent('Invoice')", "10000"
    assert_equal "YDIM", get_title
    assert !is_text_present("Invoice")

    click "link=Bezahlte Rechnungen"
    wait_for_condition "selenium.isTextPresent('Invoice')", "10000"
    assert is_text_present("Invoice")
  end
  def test_invoices__collect_garbage
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    invoice = YDIM::Invoice.new(10001)
    invoice.debitor = debitor
    invoice.description = 'Invoice'
    flexstub(invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100', 
                          :quantity => 5)
    invoice.add_item(item)

    session = login([debitor])
    assert_equal "YDIM", get_title
    session.should_receive(:debitor).and_return(debitor)
    session.should_receive(:invoice).and_return(invoice)
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Invoice")

    click "link=löschen"
    wait_for_condition "!selenium.isTextPresent('Invoice')", "10000"
    assert_equal "YDIM", get_title
    assert !is_text_present("Invoice")

    click "link=Papierkorb"
    wait_for_condition "selenium.isTextPresent('Invoice')", "10000"
    assert is_text_present("Invoice")

    session.should_receive(:collect_garbage)
    click "collect_garbage"
    wait_for_condition "!selenium.isTextPresent('Invoice')", "10000"
    assert !is_text_present("Invoice")
  end
end
    end
  end
end
