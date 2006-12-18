#!/usr/bin/env ruby
# Selenium::TestDebitors -- ydim -- 14.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'selenium/unit'
require 'ydim/debitor'

module YDIM
  module Html
    module Selenium
class TestDebitors < Test::Unit::TestCase
  include Selenium::TestCase
  def test_debitors
    debitor1 = YDIM::Debitor.new(1)
    debitor1.name = 'Foo'
    debitor1.email = 'debitor@ywesee.com'
    debitor1.phone = '0041435400549'
    debitor1.debitor_type = 'dt_pharmacy'
    debitor2 = YDIM::Debitor.new(2)
    debitor2.name = 'Bar'
    debitor2.debitor_type = 'dt_consulting'
    flexstub(debitor2).should_receive(:next_invoice_date).and_return(Date.today)
    session = login([debitor1, debitor2])
    assert_equal "YDIM", @selenium.get_title
    assert_equal "2", @selenium.get_text("//tr[2]/td[1]")
    assert_equal "Bar", @selenium.get_text("//tr[2]/td[2]")
    assert_equal "Beratung", @selenium.get_text("//tr[2]/td[6]")
    assert_equal "1", @selenium.get_text("//tr[3]/td[1]")
    assert_equal "Foo", @selenium.get_text("//tr[3]/td[2]")
    assert_equal "debitor@ywesee.com", 
      @selenium.get_text("//tr[3]/td[3]")
    assert_equal "0041435400549", 
      @selenium.get_text("//tr[3]/td[4]")
    assert_equal "Apotheke", @selenium.get_text("//tr[3]/td[6]")

    @selenium.click "link=ID"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "1", @selenium.get_text("//tr[2]/td[1]")
    assert_equal "2", @selenium.get_text("//tr[3]/td[1]")
  end
end
    end
  end
end
