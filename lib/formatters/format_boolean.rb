module Formatters
	class FormatBoolean < Format
		def from(value, options = {})
			value ? 'yes' : 'no'
		end

		def to(str, options = {})
			str == 'yes'
		end
	end
end
