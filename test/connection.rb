require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:",
	:timeout => 500
)

load File.dirname(__FILE__) + "/fixtures/schema.rb"

