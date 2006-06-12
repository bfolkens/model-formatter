module Formatters
	class FormatDecimal < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_with_delimiter number_with_precision(value)
		end

		def to(str)
			str.gsub(/,/, '').to_f
		end
	end
end
