require 'rubygems'
require 'action_view'

module Formatters
	class FormatDecimal < Format
		include ActionView::Helpers::NumberHelper

		def initialize(options = {})
		end

		def from(value, options = {})
		  options = {:precision => 3, :delimiter => ','}.merge(options)
			number_with_delimiter number_with_precision(value, options[:precision]), options[:delimiter]
		end

		def to(str, options = {})
			return nil if str.nil? or str.empty?
			str.gsub(/,/, '').to_f
		end
	end
end
