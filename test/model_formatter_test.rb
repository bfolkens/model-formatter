require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_view'
require File.dirname(__FILE__) + '/connection'
RAILS_ROOT = File.dirname(__FILE__)

$: << "../lib"

require 'model_formatter'
require File.dirname(__FILE__) + '/fixtures/entry'


class ModelFormatterTest < Test::Unit::TestCase
	def setup
		Entry.format_column :some_integer, :as => :integer
		Entry.format_column :some_boolean, :prefix => 'fmt_', :as => :boolean

		Entry.format_column :sales_tax, :as => :currency, :options => {:precision => 3}
		Entry.format_column :super_precise_tax, :as => Formatters::FormatCurrency.new(:precision => 6)

		Entry.format_column :area, :from => Proc.new {|value, options| sprintf('%2d', value) + options[:sample_format]},
															 :to => Proc.new {|str, options| str.gsub(/[^0-9]/, '').to_i},
															 :options => {:sample_format => ' sq. ft.'}

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
	
	def test_should_define_format_accessors
	  assert Entry.respond_to?('formatted_some_integer_formatter')
	  assert Entry.respond_to?('formatted_some_integer_unformatter')
  end

	def test_should_define_getters
		assert Entry.new.respond_to?('formatted_some_integer')
		assert Entry.new.respond_to?('fmt_some_boolean')
		assert Entry.new.respond_to?('formatted_sales_tax')
		assert Entry.new.respond_to?('formatted_super_precise_tax')
		assert Entry.new.respond_to?('formatted_area')
		assert Entry.new.respond_to?('formatted_complex_field')
		assert Entry.new.respond_to?('formatted_phone')
	end

	def test_should_define_setters
		assert Entry.new.respond_to?('formatted_some_integer=')
		assert Entry.new.respond_to?('fmt_some_boolean=')
		assert Entry.new.respond_to?('formatted_sales_tax=')
		assert Entry.new.respond_to?('formatted_super_precise_tax=')
		assert Entry.new.respond_to?('formatted_area=')
		assert Entry.new.respond_to?('formatted_complex_field=')
		assert Entry.new.respond_to?('formatted_phone=')
	end
	
	def test_should_know_formatters
	  assert !Entry.is_formatted?(:id)

		assert Entry.is_formatted?(:some_integer)
		assert Entry.is_formatted?(:some_boolean)
		assert Entry.is_formatted?(:sales_tax)

		assert Entry.is_formatted?('super_precise_tax')
		assert Entry.is_formatted?('area')
		assert Entry.is_formatted?('complex_field')
		assert Entry.is_formatted?('phone')
  end

	def test_should_respond_to_basic_definition
		e = Entry.new
		
		assert_equal '3,123', Entry.formatted_some_integer_formatter(3123)
		e.some_integer = 3123
		assert_equal '3,123', e.formatted_some_integer

		assert_equal 3123, Entry.formatted_some_integer_unformatter('3,123')
		e.formatted_some_integer = '3,123'
		assert_equal 3123, e.some_integer
	end

	def test_should_respond_to_proc_definition
		e = Entry.new
		
		assert_equal '3123 sq. ft.', Entry.formatted_area_formatter(3123)
		e.area = 3123
		assert_equal '3123 sq. ft.', e.formatted_area

		assert_equal 3123, Entry.formatted_area_unformatter('3123 sq. ft.')
		e.formatted_area = '3123 sq. ft.'
		assert_equal 3123, e.area
	end

	def test_should_respond_to_block_definition
		e = Entry.new
		
		assert_equal 'bouya test me', Entry.formatted_complex_field_formatter('test me')
		e.complex_field = 'test me'
		assert_equal 'bouya test me', e.formatted_complex_field

		assert_equal 'here and bouya there', Entry.formatted_complex_field_unformatter('bouya here and bouya there')
		e.formatted_complex_field = 'bouya here and bouya there'
		assert_equal 'here and bouya there', e.complex_field
	end

	def test_should_pass_options_upon_instantiation
		e = Entry.new
		
		# Check format accessors
		assert_equal '$12,412.292', Entry.formatted_sales_tax_formatter(12412292)
		assert_equal 12412292, Entry.formatted_sales_tax_unformatter('$12,412.292')
		
		# Check symbol use		
		e.sales_tax = 12412292
		assert_equal '$12,412.292', e.formatted_sales_tax

		e.formatted_sales_tax = '$12,412.292'
		assert_equal 12412292, e.sales_tax

    # Check instance use
		e.super_precise_tax = 12412292888
		assert_equal '$12,412.292888', e.formatted_super_precise_tax		

		e.formatted_super_precise_tax = '$12,412.292888'
		assert_equal 12412292888, e.super_precise_tax
	end
end

