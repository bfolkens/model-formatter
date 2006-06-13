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
		Entry.format_column :some_integer, :as => :integer
		Entry.format_column :some_boolean, :prefix => 'fmt_', :as => :boolean
		Entry.format_column :sales_tax, :as => Formatters::FormatCurrency
		Entry.format_column :area, :from => Proc.new {|value, options| sprintf('%2d', value) + ' sq. ft.'},
															 :to => Proc.new {|str, options| str.gsub(/[^0-9]/, '')}
		Entry.format_column :complex_field do
			def from(value, options = {})
				'bouya ' + value
			end

			def to(str, options = {})
				str.gsub(/^bouya /, '')
			end
		end
		Entry.format_column :phone, :as => :phone
	end

	def test_should_define_getters
		assert Entry.new.respond_to?('formatted_some_integer')
		assert Entry.new.respond_to?('fmt_some_boolean')
		assert Entry.new.respond_to?('formatted_sales_tax')
		assert Entry.new.respond_to?('formatted_area')
		assert Entry.new.respond_to?('formatted_complex_field')
		assert Entry.new.respond_to?('formatted_phone')
	end

	def test_should_define_setters
		assert Entry.new.respond_to?('formatted_some_integer=')
		assert Entry.new.respond_to?('fmt_some_boolean=')
		assert Entry.new.respond_to?('formatted_sales_tax=')
		assert Entry.new.respond_to?('formatted_area=')
		assert Entry.new.respond_to?('formatted_complex_field=')
		assert Entry.new.respond_to?('formatted_phone=')
	end

	def test_should_respond_to_basic_definition
		e = Entry.new
		e.some_integer = 3123
		assert_equal '3,123', e.formatted_some_integer

		e.formatted_some_integer = '3,123'
		assert_equal 3123, e.some_integer
	end

	def test_should_respond_to_proc_definition
		e = Entry.new
		e.area = 3123
		assert_equal '3123 sq. ft.', e.formatted_area

		e.formatted_area = '3123 sq. ft.'
		assert_equal 3123, e.area
	end

	def test_should_respond_to_block_definition
		e = Entry.new
		e.complex_field = 'test me'
		assert_equal 'bouya test me', e.formatted_complex_field

		e.formatted_complex_field = 'bouya here and bouya there'
		assert_equal 'here and bouya there', e.complex_field
	end
end

