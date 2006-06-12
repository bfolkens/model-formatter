print "Using native MySQL\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "test",
  :socket => "/var/run/mysqld/mysqld.sock"
)

load File.dirname(__FILE__) + "/fixtures/schema.rb"

