require 'rubygems'
require 'action_view'

module Formatters
	class FormatCurrency < Format
		include ActionView::Helpers::NumberHelper

		def initialize(options = {})
			@precision = options[:precision] || 2
		end

		def from(value, options = {})
		  options = {:precision => @precision}.merge(options)
			number_to_currency(value.to_f / (10 ** @precision), options)
		end

		def to(str, options = {})
			return nil if str.nil? or str.empty?
			val = str.gsub(/[^0-9.]/, '').to_f
			(val * (10 ** @precision)) unless val.nil?
		end
	end
end
