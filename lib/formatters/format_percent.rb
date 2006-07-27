require 'rubygems'
require 'action_view'

module Formatters
	class FormatPercent < Format
		include ActionView::Helpers::NumberHelper

		def initialize(options = {})
		end

		def from(value, options = {})
			number_to_percentage value, options
		end

		def to(str, options = {})
			return nil if str.nil? or str.empty?
			str.gsub(/[^0-9\.]/, '').to_f
		end
	end
end
