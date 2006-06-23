require 'rubygems'
require 'action_view'

module Formatters
	class FormatInteger < Format
		include ActionView::Helpers::NumberHelper

		def initialize(options = {})
		end

		def from(value, options = {})
		  options = {:delimiter => ','}.merge(options)
			number_with_delimiter value, options[:delimiter]
		end

		def to(str, options = {})
			return nil if str.nil? or str.empty?
			str.gsub(/,/, '').to_i
		end
	end
end
