require 'rubygems'
require 'action_view'

module Formatters
	class FormatPhone < Format
		include ActionView::Helpers::NumberHelper

		def from(value, options = {})
			number_to_phone value
		end

		def to(str, options = {})
			return nil if str.nil? or str.empty?
			str.gsub(/[^0-9]/, '').to_i
		end
	end
end
