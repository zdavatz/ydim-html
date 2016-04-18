#!/usr/bin/env ruby
# encoding: utf-8
# Html::View::Debitors -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'ydim/html/view/template'
require 'htmlgrid/formlist'

module YDIM
	module Html
		module View
class DebitorList < HtmlGrid::FormList
	COMPONENTS = {
		[0,0]	=>	:unique_id,
		[1,0]	=>	:name,
		[2,0]	=>	:email,
		[3,0]	=>	:phone,
		[4,0]	=>	:next_invoice_date,
		[5,0]	=>	:debitor_type,
	}
	EVENT = :create_debitor
	SORT_DEFAULT = nil
	def debitor_type(model)
		@lookandfeel.lookup(model.debitor_type)
	end
	def next_invoice_date(model)
		if(date = model.next_invoice_date)
			@lookandfeel.format_date(date)
		end
	end
	def phone(model)
		if(phone = model.phone)
			link = HtmlGrid::Link.new(:phone, model, @session, self)
			link.href = "callto://#{phone.delete(' ')}"
			link.value = phone
			link
		end
	end
	links :debitor, :name, :unique_id
end
class Debitors < Template
	CONTENT = DebitorList
end
		end
	end
end
