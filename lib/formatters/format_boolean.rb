module Formatters
	class FormatBoolean < Format
		def from(value)
			value ? 'yes' : 'no'
		end

		def to(str)
			str == 'yes'
		end
	end
end
