require 'rubygems'
require 'action_view'

module Formatters
	class FormatDecimal < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_with_delimiter number_with_precision(value)
		end

		def to(str)
			return nil if str.nil? or str.empty?
			str.gsub(/,/, '').to_f
		end
	end
end
