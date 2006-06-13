module ModelFormatter # :nodoc:
	def self.append_features(base) # :nodoc:
		super
		base.extend(ClassMethods)
	end

	def self.init_options(defaults, model, attr) # :nodoc:
		options = defaults.dup
		options[:attr] = attr
		options[:prefix] ||= "formatted_"
		options[:formatted_attr] ||= "#{options[:prefix]}#{attr}"

		# If :as is set, then it must be either a formatter Class, Symbol, or String
		options[:as] = formatter_class_for(options[:as]) unless options[:as].nil?

		# Define the :as from a :block if :block is defined
		options[:as] = define_formatter(attr, &options[:block]) unless options[:block].nil?

		# Instantiate the formatter for this attribute if we've been called with :as or a block
		options[:formatter] = options[:as].new unless options[:as].nil?

		# Define :formatter from a block based on :from and :to if they're both set
		if !options[:from].nil? and !options[:to].nil?
			options[:formatter] = Module.new
			options[:formatter].class.send :define_method, :from, options[:from]
			options[:formatter].class.send :define_method, :to, options[:to]
		end

		# If :as is still not defined raise an error
		raise 'No formatting options have been defined.' if options[:formatter].nil?

		options
	end

	# Define a formatter like the actual physical classes
	# this could easily be done with text similar to the exact
	# layout of the format classes, but this should be faster.
	def self.define_formatter(attr, &formatter) # :nodoc:
		# The convention is to name these custom formatters
		# differently than the other formatting classes
		class_name = "CustomFormat#{attr.to_s.camelize}"

		# Create a class in the same module as the others
		clazz = Class.new(Formatters::Format)
		silence_warnings do
			Formatters.const_set class_name, clazz
		end

		# Define the class body
		clazz.class_eval &formatter
		return clazz
	end

	# Return the formatter class for a class, symbol, or string defining
	# the name of a formatter class.	If it's a symbol, check the Formatters
	# module for the class that matches the camelized name of the symbol
	# with 'Format' prepended.
	def self.formatter_class_for(type_name) # :nodoc:
		# If the type_name is a class, don't do anything to it
		formatter_class = type_name if type_name.kind_of? Class

		# Format a symbol or string into a formatter_class
		if type_name.is_a? Symbol or type_name.is_a? String
			type_name = type_name.to_s.capitalize

			# Construct the class name from the type_name
			formatter_name = "Format#{type_name}"
			formatter_class = nil
			begin
				formatter_class = Formatters.const_get(formatter_name)
			rescue NameError => ne
				# Ignore this, caught below
			end
		end

		# Make sure the name of this is found in the Formatters module and that
		# it's the correct superclass
		return formatter_class unless formatter_class.nil? or
																	formatter_class.superclass != Formatters::Format

		raise Formatters::FormatNotFoundException.new("Cannot find formatter 'Formatters::#{formatter_name}'")
	end

	require File.dirname(__FILE__) + '/formatters.rb'
 
	# == Usage
	#  class Widget < ActiveRecord::Base
	#    # Set an integer field as a symbol
	#    format_column :some_integer, :as => :integer
	#
	#    # Specify the type as a class
	#    format_column :sales_tax, :as => Formatters::FormatCurrency
	#
	#    # Change the prefix of the generated methods and specify type as a symbol
	#    format_column :sales_tax, :prefix => 'fmt_', :as => :currency, :options => {:on_empty => 'N/A'}
	#
	#    # Use specific procedures to convert the data +from+ and +to+ the target
	#    format_column :area, :from => Proc.new {|value, options| number_with_delimiter sprintf('%2d', value)},
	#                         :to => Proc.new {|str, options| str.gsub(/,/, '')}
	#
	#    # Use a block to define the formatter methods
	#    format_column :sales_tax do
	#      def from(value, options = {})
	#        number_to_currency value
	#      end
	#      def to(str, options = {})
	#        str.gsub(/[\$,]/, '')
	#      end
	#    end
	#
	#    ...
	#  end
	module ClassMethods
		# You can override the default options with +model_formatter+'s +options+ parameter
		DEFAULT_OPTIONS = {
			:prefix => nil,
			:formatted_attr => nil,
			:as => nil,
			:from => nil,
			:to => nil,
			:options => nil
		}.freeze

		# After calling "<tt>format_column :sales_tax</tt>" as in the example above, a number of instance methods
		# will automatically be generated, all prefixed by "formatted_" unless :prefix or :formatter_attr
		# have been set:
		#
		# * <tt>Widget#formatted_sales_tax=(value)</tt>: This will set the <tt>sales_tax</tt> of the widget using the value stripped of its formatting.
		# * <tt>Widget#formatted_sales_tax</tt>: This will return the <tt>sales_tax</tt> of the widget using the formatter specified in the options to +format+.
		# * <tt>Widget#sales_tax_formatting_options</tt>: Access the options this formatter was created with.  Useful for declaring field length and later referencing it in display helpers.
		#
		# === Options:
		# * <tt>:formatted_attr</tt>  - The actual name used for the formatted attribute.  By default, the formatted attribute
		#   name is composed of the <tt>:prefix</tt>, followed by the name of the attribute.
		# * <tt>:prefix</tt>   - Change the prefix prepended to the formatted columns.  By default, formatted columns
		#   are prepended with "formatted_".
		# * <tt>:as</tt>       - Format the column as the specified format.  This can be provided in either a String,
		#   a Symbol, or as a Class reference to the formatter.  The class should subclass Formatters::Format and define <tt>from(value, options = {})</tt> and <tt>to(str, options = {})</tt>.
		# * <tt>:from</tt>     - Data coming from the attribute retriever method is sent to this +Proc+, then returned as a
		#   manipulated attribute.
		# * <tt>:to</tt>       - Data being sent to the attribute setter method is sent to this +Proc+ first to be manipulated,
		#   and the returned attribute is then sent to the attribute setter.
		# * <tt>:options</tt>  - Passed to the formatter blocks and/or methods as additional formatting options.
		def format_column(attr, options={}, &fmt_block)
			options[:block] = fmt_block if block_given?
			options = DEFAULT_OPTIONS.merge(options) if options

			# Create the actual options
			my_options = ModelFormatter::init_options(options, 
																								Inflector.underscore(self.name).to_s,
																								attr.to_s)

			# Define the setter for attr
			define_method my_options[:formatted_attr] do ||
				value = self.send(attr)
				return value if value.nil?

				from_method = my_options[:formatter].method(:from)
				from_method.call(value, my_options[:options])
			end

			# Define the getter for attr
			define_method my_options[:formatted_attr] + '=' do |str|
				to_method = my_options[:formatter].method(:to)
				value = to_method.call(str, my_options[:options])

				self.send(attr.to_s + '=', value)
			end

			# This creates a closure keeping a reference to my_options
			# right now that's the only way we store the options. We
			# might use a class attribute as well
			define_method "#{attr}_formatting_options" do
				my_options
			end
		end

	end
end
