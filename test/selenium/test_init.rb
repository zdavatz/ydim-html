#!/usr/bin/env ruby
# Selenium::TestInit -- ydim -- 14.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'selenium/unit'

module YDIM
  module Html
    module Selenium
class TestInit < Test::Unit::TestCase
  include Selenium::TestCase
  def test_init
    open "/"
    assert_equal "YDIM", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("login")
    assert_equal('Email', get_text("//label[@for='email']"))
    assert_equal('Passwort', get_text("//label[@for='pass']"))
  end
  def test_login__fail__empty
    open "/"
    assert_equal "YDIM", get_title
    #type "email", "unknown@ywesee.com"
    #type "pass", "wrong"
    click "login"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("login")
    assert_equal('Email', get_text("//label[@for='email']"))
    assert_equal('Passwort', get_text("//label[@for='pass']"))
  end
  def test_login__fail__both
    open "/"
    assert_equal "YDIM", get_title
    type "email", "unknown@ywesee.com"
    type "pass", "incorrect"
    click "login"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("login")
    assert_equal('Email', get_text("//label[@for='email']"))
    assert_equal('Passwort', get_text("//label[@for='pass']"))
  end
  def test_login__fail__email
    open "/"
    assert_equal "YDIM", get_title
    type "email", "unknown@ywesee.com"
    type "pass", "secret"
    click "login"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("login")
    assert_equal('Email', get_text("//label[@for='email']"))
    assert_equal('Passwort', get_text("//label[@for='pass']"))
  end
  def test_login__fail__pass
    open "/"
    assert_equal "YDIM", get_title
    type "email", "test@ywesee.com"
    type "pass", "incorrect"
    click "login"
    wait_for_page_to_load "30000"
    assert_equal "YDIM", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("login")
    assert_equal('Email', get_text("//label[@for='email']"))
    assert_equal('Passwort', get_text("//label[@for='pass']"))
  end
  def test_login__success
    login
    assert_equal "YDIM", get_title
    assert !is_element_present("email")
    assert !is_element_present("pass")
    assert !is_element_present("login")
    assert is_element_present("logout")
  end
  def test_logout
    login
    assert_equal "YDIM", get_title
    assert !is_element_present("email")
    assert !is_element_present("pass")
    assert !is_element_present("login")
    assert is_element_present("logout")

    click "logout"
    wait_for_page_to_load "30000"
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("login")
    assert !is_element_present("logout")
  end
end
    end
  end
end
