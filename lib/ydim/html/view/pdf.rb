#!/usr/bin/env ruby
# Html::View::Pdf -- ydim -- 17.01.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'

module YDIM
	module Html
		module View
class Pdf < HtmlGrid::Component
  def to_html(context)
    @model.to_pdf :sortby => (@session.state.sortby || []).first,
                  :sort_reverse => @session.state.sort_reverse
  end
	def http_headers(*args)
		super.update(
			'Content-Type'				=>	'application/pdf',
			'Content-Disposition' =>  "attachment; filename=#{@model.unique_id}.pdf"
		)
	end
end
		end
	end
end
