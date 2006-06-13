require 'rubygems'
require 'action_view'

module Formatters
	class FormatCurrency < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_to_currency value
		end

		def to(str)
			return nil if str.nil? or str.empty?
			str.gsub(/[$,]/, '')
		end
	end
end
