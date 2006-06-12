module Formatters
	class FormatInteger < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_with_delimiter value
		end

		def to(str)
			str.gsub(/,/, '').to_i
		end
	end
end
