module Formatters
	BASE_PATH = File.join(File.dirname(__FILE__), 'formatters')

	require File.join(BASE_PATH, 'format.rb')
	Dir[File.join(BASE_PATH, 'format_*.rb')].each do |formatter|
		require formatter
	end
end
