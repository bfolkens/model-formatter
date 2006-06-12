module Formatters
	class Format
		def from(value)
			raise FormatNotDefinedException
		end

		def to(str)
			raise FormatNotDefinedException
		end
	end

	class FormattingException
	end

	class FormatNotDefinedException
	end

	class FormatNotFoundException
	end
end
