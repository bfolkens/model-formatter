module Formatters
	class Format
		def from(value)
			raise FormatNotDefinedException
		end

		def to(str)
			raise FormatNotDefinedException
		end
	end

	class FormattingException < Exception
	end

	class FormatNotDefinedException < Exception
	end

	class FormatNotFoundException < Exception
	end
end
