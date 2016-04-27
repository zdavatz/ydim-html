#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

describe "ydim-html" do
  include FlexMock::TestCase

  before :all do
    @idx ||= 0
    puts "setup_ydim_test before all @browser is #{@browser} @idx #{@idx}"
  end

  before :each do
    @idx += 1
    puts "before each @idx: #{@idx}"
    setup_ydim_test
#    waitForYdimToBeReady(@browser)
  end

  after :each do
    @idx += 10
    puts "after each @idx: #{@idx}"
    teardown_ydim_test
#    createScreenshot(@browser, '_'+@idx.to_s)
  end
  after :all do
    puts "after :all @browser #{@browser.class}"
    $browser.close if $browser
  end

  if false

    # next test work, if only one test is invoked, else we get nil error
  it "should allow to log in" do
    @browser.goto "#{YDIM::Html.config.http_server}:10080/de/"
    windowSize = @browser.windows.size
    expect(@browser.url).to match YDIM::Html.config.http_server
    text = @browser.text.clone
    binding.pry unless /Email/.match text
    expect(text).to match /Email\nPasswort\n/
    expect(@browser.title).to eql 'YDIM'
    @browser.element(:name => 'email').wait_until_present
    @browser.text_field(:name => 'email').set 'test@ywesee.com'
    @browser.element(:name => 'pass').wait_until_present
    @browser.text_field(:name => 'pass').set 'secret'
    @browser.element(:name => 'login').wait_until_present
    expect(@browser.forms.size).to eql 1
    @browser.forms.first.submit
    # @browser.button(:name => 'login').click
    text = @browser.text.clone
    expect(text).to match /Rechnungen/
  end

    # next test work, if only one test is invoked, else we get nil error
  it "should use login 1" do
    login
  end
  end
  def setup_debitor
    debitor = YDIM::Debitor.new(1)
    debitor.name = 'Foo'
    debitor.email = 'debitor@ywesee.com'
    debitor.phone = '0041435400549'
    debitor.debitor_type = 'dt_pharmacy'
    debitor
  end
  it "should succedd creating an invoice" do
    debitor = setup_debitor
    session = login([debitor])
    session.should_receive(:debitor).and_return(debitor)
    expect(@browser.title).to eql 'YDIM'
    # binding.pry
    TODO = %(
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
        item.send("\#{key}=", val)
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
)
  end
end

