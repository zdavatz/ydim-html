#!/usr/bin/env ruby
# Html::Selenium::TestInvoices -- ydim -- 15.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'ostruct'
require 'selenium/unit'

module YDIM
  module Html
    module Selenium
class TestInvoices < Test::Unit::TestCase
  include Selenium::TestCase
  def setup_info(id, payment, status, deleted)
    info = OpenStruct.new
    info.unique_id = id
    info.debitor_name = 'Customer, longer than 30 Characters'
    info.debitor_email = 'test@ywesee.com'
    info.description = "Invoice #{id}, #{status}"
    info.date = Date.today
    info.payment_received = payment
    info.total_netto = 100
    info.total_brutto = 107.6
    info.currency = 'CHF'
    info.status = status
    info.deleted = deleted
    info.odba_store = true
    info
  end
  def test_invoices
    session = login([])
    info1 = setup_info(1, false, 'is_open', false)
    info2 = setup_info(2, false, 'is_due', false)
    info3 = setup_info(3, true, 'is_paid', false)
    info4 = setup_info(4, false, 'is_trash', true)
    infos = [info1, info2, info3, info4]
    session.should_receive(:invoice_infos).and_return { |status|
      infos.select { |info| info.status == status }
    }
    assert_equal "YDIM", get_title
    click "link=Rechnungen"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert_equal "is_open", get_attribute("//tr[2]@class")
    assert is_text_present("Invoice 1, is_open")
    assert is_text_present('Customer, longer than 30 Ch...')
    assert is_text_present("Invoice 2, is_due")
    assert !is_text_present("Invoice 3, is_paid")
    assert !is_text_present("Invoice 4, is_trash")

    click "link=Fällige Rechnungen"
    wait_for_condition "selenium.isTextPresent('Invoice 2')", "10000"
    assert_equal "is_due", get_attribute("//tr[2]@class")
    assert !is_text_present("Invoice 1, is_open")
    assert is_text_present("Invoice 2, is_due")
    assert !is_text_present("Invoice 3, is_paid")
    assert !is_text_present("Invoice 4, is_trash")

    click "link=Bezahlte Rechnungen"
    wait_for_condition "selenium.isTextPresent('Invoice 3')", "10000"
    assert_equal "is_paid", get_attribute("//tr[2]@class")
    assert !is_text_present("Invoice 1, is_open")
    assert !is_text_present("Invoice 2, is_due")
    assert is_text_present("Invoice 3, is_paid")
    assert !is_text_present("Invoice 4, is_trash")

    click "link=Papierkorb"
    wait_for_condition "selenium.isTextPresent('Invoice 4')", "10000"
    assert_equal "is_trash", get_attribute("//tr[2]@class")
    assert !is_text_present("Invoice 1, is_open")
    assert !is_text_present("Invoice 2, is_due")
    assert !is_text_present("Invoice 3, is_paid")
    assert is_text_present("Invoice 4, is_trash")

    click "link=Offene Rechnungen"
    wait_for_condition "selenium.isTextPresent('Invoice 1')", "10000"
    assert is_text_present("Invoice 1, is_open")
  end
  def test_invoices__paid
    session = login([])
    info1 = setup_info(1, false, 'is_open', false)
    session.should_receive(:invoice_infos).and_return { |status|
      [info1]
    }
    assert_equal "YDIM", get_title
    click "link=Rechnungen"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Invoice 1, is_open")

    session.should_receive(:invoice).and_return { 
      info1.status = 'is_paid'
      info1
    }
    click "link=offen"
    wait_for_condition "!selenium.isTextPresent('Invoice 1')", "10000"
    assert !is_text_present("Invoice 1, is_open")
    click "link=Bezahlte Rechnungen"
    wait_for_condition "selenium.isTextPresent('Invoice 1')", "10000"
    assert is_text_present("Invoice 1, is_open")
  end
  def test_invoices__deleted
    session = login([])
    info1 = setup_info(1, false, 'is_open', false)
    session.should_receive(:invoice_infos).and_return { |status|
      [info1]
    }
    assert_equal "YDIM", get_title
    click "link=Rechnungen"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Invoice 1, is_open")

    session.should_receive(:invoice).and_return { 
      info1.status = 'is_trash'
      info1
    }
    click "link=löschen"
    wait_for_condition "!selenium.isTextPresent('Invoice 1')", "10000"
    assert !is_text_present("Invoice 1, is_open")
    click "link=Papierkorb"
    wait_for_condition "selenium.isTextPresent('Invoice 1')", "10000"
    assert is_text_present("Invoice 1, is_open")
  end
  def test_invoices__collect_garbage
    session = login([])
    info1 = setup_info(1, false, 'is_trash', true)
    session.should_receive(:invoice_infos).and_return { |status|
      status == 'is_trash' ? [info1] : []
    }
    assert_equal "YDIM", get_title
    click "link=Rechnungen"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert !is_text_present("Invoice 1, is_trash")

    click "link=Papierkorb"
    wait_for_condition "selenium.isTextPresent('Invoice 1')", "10000"
    assert is_text_present("Invoice 1, is_trash")
    assert is_element_present("collect_garbage")

    session.should_receive(:collect_garbage).times(1)
    click "collect_garbage"
    wait_for_condition "!selenium.isTextPresent('Invoice 1')", "10000"
    assert !is_text_present("Invoice 1, is_trash")
    assert !is_element_present("collect_garbage")
  end
  def test_invoices__mail
    session = login([])
    info1 = setup_info(1, false, 'is_due', false)
    session.should_receive(:invoice_infos).and_return { |status|
      status == 'is_due' ? [info1] : []
    }
    assert_equal "YDIM", get_title
    click "link=Rechnungen"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_text_present("Invoice 1, is_due")

    click "link=Fällige Rechnungen"
    wait_for_condition "selenium.isTextPresent('Invoice 1')", "10000"
    assert is_text_present("Invoice 1, is_due")
    assert is_element_present("send_invoice")

    session.should_receive(:send_invoice).times(1).and_return { 
      ['customer@ywesee.com', 'admin@ywesee.com']
    }
    click "link=Email Senden"
    wait_for_page_to_load "30000"
    assert is_text_present("Die Rechnung wurde an folgende Email-Adressen verschickt: customer@ywesee.com, admin@ywesee.com")
  end
end
    end
  end
end
