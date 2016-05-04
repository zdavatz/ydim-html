#!/usr/bin/env ruby
# encoding: utf-8
# require 'simplecov'
# SimpleCov.start
$: << File.expand_path('../../lib', File.dirname(__FILE__))
require 'ydim/html/config'
require 'digest'
require 'minitest/autorun'
require 'flexmock/test_unit'
require_relative 'stub/http_server'
require 'ydim/html/util/server'
require 'watir'
require "watir-webdriver/wait"
begin
  require 'pry'
rescue LoadError
end

RSpec.configure do |config|
  config.mock_with :flexmock
  config.expect_with :rspec do |c|
    c.syntax = [:expect]
  end
end

BreakIntoPry = false
begin
  require 'pry'
rescue LoadError
  # ignore error for Travis-CI
end

@homeUrl ||= "http://localhost:8752"
YdimUrl = @homeUrl
ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exists?(ImageDest)
$browser ||= Watir::Browser.new :chrome
WEBrick::BasicLog.new(nil, WEBrick::BasicLog::DEBUG)

def setup_ydim_test
  @browser = $browser
  include FlexMock::TestCase
  YDIM::Html.config.email = 'test@ywesee.com'
  YDIM::Html.config.md5_pass = Digest::MD5.hexdigest('secret')
  YDIM::Html.config.config=['/tmp/ignore_if_not_exists']

  debitors=[]
  session = flexmock('session')
  @ydim_server =  flexmock('ydim_server')
  @ydim_server.should_receive(:login).and_return(session).by_default
  @ydim_server.should_receive(:logout)
  session.should_receive(:debitors).and_return(debitors)
# created ssh-keygen -f id_dsa -t dsa (with empty-passphrase
  @server = YDIM::Html::Util::Server.new(@ydim_server)
  @server.extend(DRbUndumped)
  drb_url = "druby://localhost:10081"
  @drb = Thread.new {
    @drb_server = DRb.start_service(drb_url, @server)
  }
  @drb.abort_on_exception = true
  @http_server = YDIM::Html::Stub.http_server(drb_url)
  @http_server.logger.level = WEBrick::BasicLog::DEBUG
  @webrick = Thread.new { @http_server.start }
  puts "setup_ydim_test #{@http_server.class} #{@drb_server.class}"
end

def teardown_ydim_test
  @http_server ||= false
  @drb_server ||= false
  puts "teardown_ydim_test #{@http_server.class} #{@drb_server.class} @browser #{@browser.class}"
  @drb_server.stop_service if @drb_server
  @http_server.shutdown if @http_server
  @ydim_server = nil
end

def small_delay
  sleep(0.1)
end

def createScreenshot(browser=@browser, added=nil)
  small_delay
  if browser.url.index('?')
    name = File.join(ImageDest, File.basename(browser.url.split('?')[0]).gsub(/\W/, '_'))
  else
    name = File.join(ImageDest, browser.url.split('/')[-1].gsub(/\W/, '_'))
  end
  name = "#{name}#{added}.png"
  browser.screenshot.save (name)
  puts "createScreenshot: #{name} done" if $VERBOSE
end

def login(debitors=[])
  session = flexmock('session')
  @ydim_server.should_receive(:login).and_return(session).by_default
  session.should_receive(:debitors).and_return(debitors)
  @ydim_server.should_receive(:logout)
  # @browser.link(:name => 'logout').click if @browser.link(:name => 'logout').present?
  @browser.goto "#{YDIM::Html.config.http_server}:10080/"
  sleep 0.5
  puts @browser.text
  @browser.element(:name => 'email').wait_until_present(3) # wait at most 3 seconds
  expect(@browser.title).to eql 'YDIM'
  expect(@browser.text).to match /Email\nPasswort\n/
  @browser.text_field(:name => 'email').set 'test@ywesee.com'
  @browser.element(:name => 'pass').wait_until_present
  @browser.text_field(:name => 'pass').set 'secret'
  @browser.element(:name => 'login').wait_until_present
  @browser.forms.first.submit

  converter = flexmock('session')
  converter.should_receive(:convert).and_return { |amount, from, to|
    amount
  }
  session.should_receive(:currency_converter).and_return(converter)
  session
end

