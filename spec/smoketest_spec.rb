#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'ydim/invoice'

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
    puts "after :all @browser #{@browser.class}  $browser #{$browser.class}"
    $browser.close if $browser
  end

    # next test work, if only one test is invoked, else we get nil error
  it "should be possible to use login from spec_helper" do
    @session = login
    debitor = OpenStruct.new
    debitor.unique_id = 1
    @session.should_ignore_missing
    @session.should_receive(:create_debitor).and_return(debitor)
    @browser.button(:name => 'create_debitor').click
    expect(@browser.url).to match /debitor/
  end if false
  it "should allow to log in" do
    @browser.goto "#{YDIM::Html.config.http_server}:10080/de/"
    windowSize = @browser.windows.size
    expect(@browser.url).to match YDIM::Html.config.http_server
    text = @browser.text.clone
    # binding.pry unless /Email/.match text
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
    expect(text).to match /Nächste Rechnung/ # UTF-8 Problem
    expect(text).to match /Rechnungen/
  end

  it "should succedd creating an invoice" do
    @session = login()
    expect(@browser.title).to eql 'YDIM'
    @debitor_values = {
      "contact" => "Contact",
      "contact_firstname" => "Firstname",
      "contact_title" => "Dr.",
      "address_lines" => "Street 45",
      "location" => "8006 Zuerich",
      "emails" => "testywesee.com",
      "phone" => "043 540 0549",
    }
    create_debitor(@debitor_values)
    check_debitor(@debitor_values)
  end if false

  def create_debitor(values= Hash.new)
    @session = login()
    # click "update"

    expect(@browser.title).to eql 'YDIM'
    @invoice = YDIM::AutoInvoice.new(10001)
    @invoice.debitor = setup_debitor
    @invoice.description = 'AutoInvoice'
    flexstub(@invoice).should_receive(:odba_store)
    item = YDIM::Item.new(:text => 'Item', :price => '100',
                          :quantity => 5)
    @invoice.add_item(item)
    expect(@browser.title).to eql 'YDIM'
    @session.should_receive(:debitor).and_return(@debitor)
    @session.should_receive(:autoinvoice).and_return(@invoice)
    @session.should_receive(:generate_invoice).and_return(@invoice)
    @session.should_ignore_missing
    binding.pry
    values.each do |key, value|
      @browser.text_field(:name => 'key').set value
    end
  end if false
  def check_debitor(values = Hash.new)
#        click "update"

    binding.pry
    expect(@browser.title).to eql 'YDIM'
    values.each do |key, value|
      expect(@browser.text_field(:name => 'key').value).to eq value
    end
  end

  def setup_debitor
    @debitor = YDIM::Debitor.new(1)
    @debitor.name = 'Foo'
    @debitor.email = 'debitor@ywesee.com'
    @debitor.phone = '0041435400549'
    @debitor.debitor_type = 'dt_pharmacy'
    @debitor
  end

  if false
    # next test work, if only one test is invoked, else we get nil error
  it "should be possible to use login from spec_helper" do
    login
  end
  it "should succedd creating an invoice" do
    # binding.pry
    TODO = %(
    click "link=Foo"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    click "create_invoice"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title

    type "description", "Newly created Invoice"

    @invoice = nil
    @session.should_receive(:create_invoice).and_return {
      @invoice = Invoice.new(10001)
      @invoice.debitor = debitor
      flexstub(invoice).should_receive(:odba_store)
      @invoice
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
    @session.should_receive(:add_items).and_return { |invoice_id, items, invoice_key|
      assert_equal(10001, invoice_id)
      assert_equal(:invoice, invoice_key)
      assert_equal(1, items.size)
      hash = items.first
      assert_instance_of(Hash, hash)
      assert_equal(1, hash.size)
      assert_instance_of(Time, hash[:time])
      item = YDIM::Item.new(hash)
      item.index = 0
      @invoice.items.push(item)
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

    @session.should_receive(:update_item).and_return { |invoice_id, item_index, data, invoice_key|
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
  end if false
  end
end

