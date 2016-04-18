#!/usr/bin/env ruby
# encoding: utf-8
# Html::View::Init -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'ydim/html/view/template'
require 'htmlgrid/pass'
require 'htmlgrid/inputtext'

module YDIM
	module Html
		module View
class InitForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]	=> :email,
		[0,1]	=> :pass,
		[1,2]	=> :submit,
	}
	EVENT = :login
	SYMBOL_MAP = {
		:email	=>	HtmlGrid::InputText,
		:pass		=>	HtmlGrid::Pass,
	}
end
class Init < Template
	CONTENT = InitForm
	FOOT = nil
end
		end
	end
end
