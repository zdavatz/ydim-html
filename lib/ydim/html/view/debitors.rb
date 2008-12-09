#!/usr/bin/env ruby
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
  CSS_ID = 'debitors'
	EVENT = :create_debitor
	SORT_DEFAULT = Proc.new { |debitor| debitor.name.to_s.downcase }
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
class DebitorsSubnavigation < HtmlGrid::DivComposite
  COMPONENTS = {
    [0,0]	=>	'debitor_type',
    [1,0] =>  '&nbsp;',
    [2,0]	=>	:debitor_type,
  }
  CSS_ID_MAP = ['subnavigation']
  SYMBOL_MAP = {
    :debitor_type => HtmlGrid::Select,
  }
  def debitor_type model
    select = HtmlGrid::Select.new :debitor_type, nil, @session, self
    select.selected = @session.user_input :debitor_type
    select.css_id = 'debitor_type'
    url = @lookandfeel._event_url(:ajax_debitors, { :debitor_type => nil })
    select.set_attribute 'onchange',
                         "javascript:reload_list('debitors', '#{url}' + this.value);"
    select
  end
end
class Debitors < Template
	CONTENT = DebitorList
  def subnavigation(model)
    DebitorsSubnavigation.new(model, @session, self)
  end
end
		end
	end
end
