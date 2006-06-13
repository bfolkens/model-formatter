require 'rubygems'
require 'action_view'

module Formatters
	class FormatPercent < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_to_percentage value
		end

		def to(str)
			return nil if str.nil? or str.empty?
			str.gsub(/[^0-9]/, '').to_f
		end
	end
end
