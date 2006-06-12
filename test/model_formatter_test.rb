require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_view'
require File.dirname(__FILE__) + '/connection'
RAILS_ROOT = File.dirname(__FILE__)

$: << "../"
$: << "../lib"

require 'init'
require File.dirname(__FILE__) + '/fixtures/entry'


class ModelFormatterTest < Test::Unit::TestCase
	def setup
		# Define these here instead of the fixture
		# so we can easily change them
		Entry.format :sales_tax, :as => Formatters::FormatCurrency
#		Entry.format :area, :from => Proc.new {
		Entry.format :phone, :as => :phone
	end

	def test_column_get_with_convert_method
		assert Entry.new.respond_to?('formatted_sales_tax')
		assert Entry.new.respond_to?('formatted_phone')
	end

	def test_column_set_with_convert_method
		assert Entry.new.respond_to?('formatted_sales_tax=')
		assert Entry.new.respond_to?('formatted_phone=')
	end

end

