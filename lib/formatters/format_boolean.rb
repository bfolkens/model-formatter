module Formatters
	class FormatBoolean < Format
		def initialize(options = {})
		  @on = 'yes'
		  @off = 'no'
		end

		def from(value, options = {})
			value ? @on : @off
		end

		def to(str, options = {})
			str == @on
		end
	end
end
