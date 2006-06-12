module Formatters
	FORMATTERS_BASE_PATH = File.join(File.dirname(__FILE__), 'formatters') unless defined? FORMATTERS_BASE_PATH

	require File.join(FORMATTERS_BASE_PATH, 'format.rb')
	Dir[File.join(FORMATTERS_BASE_PATH, 'format_*.rb')].each do |formatter|
		require formatter
	end
end
