module Formatters
	class FormatDecimal < Format
		include ActionView::Helpers::NumberHelper

		def from(value)
			number_with_precision value
		end

		def to(str)
			value.to_f
		end
	end
end
