require 'rubygems'
require 'action_view'

module Formatters
	class FormatPhone < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_to_phone value
		end

		def to(str)
			str.gsub(/[^0-9]/, '')
		end
	end
end
