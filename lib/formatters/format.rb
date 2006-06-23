module Formatters
	class Format
		def initialize(options = {})
		end

		def from(value, options = {})
			raise FormatNotDefinedException
		end

		def to(str, options = {})
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
