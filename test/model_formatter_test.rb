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
		Entry.format :some_integer, :as => :integer
		Entry.format :some_boolean, :prefix => 'fmt_', :as => :boolean
		Entry.format :sales_tax, :as => Formatters::FormatCurrency
		Entry.format :area, :from => Proc.new {|field| number_with_delimiter sprintf('%2d', field)},
												:to => Proc.new {|str| str.gsub(/,/, '')}
		Entry.format :complex_field do
			def from(value)
				'bouya' + value
			end

			def to(str)
				value.gsub(/^bouya/, '')
			end
		end
		Entry.format :phone, :as => :phone
	end

	def test_column_get_with_convert_method
		assert Entry.new.respond_to?('formatted_some_integer')
		assert Entry.new.respond_to?('fmt_some_boolean')
		assert Entry.new.respond_to?('formatted_sales_tax')
		assert Entry.new.respond_to?('formatted_area')
		assert Entry.new.respond_to?('formatted_complex_field')
		assert Entry.new.respond_to?('formatted_phone')
	end

	def test_column_set_with_convert_method
		assert Entry.new.respond_to?('formatted_some_integer=')
		assert Entry.new.respond_to?('fmt_some_boolean=')
		assert Entry.new.respond_to?('formatted_sales_tax=')
		assert Entry.new.respond_to?('formatted_area=')
		assert Entry.new.respond_to?('formatted_complex_field=')
		assert Entry.new.respond_to?('formatted_phone=')
	end
end

