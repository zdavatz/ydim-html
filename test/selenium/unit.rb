#!/usr/bin/env ruby
# Selenium::TestCase -- ydim -- 14.12.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

if(pid = Kernel.fork)
  at_exit {
    Process.kill('HUP', pid)
    $selenium.stop if($selenium.respond_to?(:stop))
  }
else
  path = File.expand_path('selenium-server.jar', File.dirname(__FILE__))
  command = "java -jar #{path} &> /dev/null"
  exec(command) 
end

require 'delegate'
require 'selenium'
require 'ydim/html/config'

module YDIM
  module Html
    module Selenium
class SeleniumWrapper < SimpleDelegator
  def initialize(host, port, browser, server, port2)
    @server = server
    @selenium = ::Selenium::SeleneseInterpreter.new(host, port, browser,
                                                    server, port2)
    super @selenium
  end
  def open(path)
    @selenium.open(@server + path)
  end
  def type(*args)
    @selenium.type(*args)
  end
end
    end
  end
end

$selenium = YDIM::Html::Selenium::SeleniumWrapper.new("localhost", 
              4444, "*chrome", 
              YDIM::Html.config.http_server + ":10080", 10000)

start = Time.now
begin
  $selenium.start
rescue Errno::ECONNREFUSED
  print "."
  sleep 1
  if((Time.now - start) > 15)
    raise
  else
    retry
  end
end

require "ydim/html/util/server"
require 'flexmock'
require 'logger'
require 'stub/http_server'
require "test/unit"

module YDIM
  module Html
    module Selenium
module TestCase
  include FlexMock::TestCase
  include SeleniumHelper
  def setup
    Html.config.email = 'test@ywesee.com'
    Html.config.md5_pass = Digest::MD5.hexdigest('secret')
    Html.logger = Logger.new($stdout)
    Html.logger.level = Logger::DEBUG
    @ydim_server = flexmock("ydim_server")
    @server = Html::Util::Server.new(@ydim_server)
    @server.extend(DRbUndumped)
    drb_url = "druby://localhost:10081"
    @drb = Thread.new { 
      @drb_server = DRb.start_service(drb_url, @server) 
    }
    @drb.abort_on_exception = true
    @http_server = Stub.http_server(drb_url)
    @webrick = Thread.new { @http_server.start }
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = SeleniumWrapper.new("localhost", 4444, "*chrome",
        Html.config.http_server + ":10080", 10000)
      @selenium.start
    end
    @selenium.set_context("TestOddb", "info")
  end
  def teardown
    @selenium.stop unless $selenium
    @http_server.shutdown
    @drb_server.stop_service
    assert_equal [], @verification_errors
    super
  end
  def login(debitors=[])
    session = flexmock('session')
    @ydim_server.should_receive(:login).and_return(session)
    session.should_receive(:debitors).and_return(debitors)
    @ydim_server.should_receive(:logout)
    @selenium.open "/"
    assert_equal "YDIM", @selenium.get_title
    @selenium.type "email", "test@ywesee.com"
    @selenium.type "pass", "secret"
    @selenium.click "login"
    @selenium.wait_for_page_to_load "30000"
    converter = flexmock('session')
    converter.should_receive(:convert).and_return { |amount, from, to| 
      amount 
    }
    session.should_receive(:currency_converter).and_return(converter)
    session
  end
end
    end
  end
end
