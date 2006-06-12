module ModelFormatter # :nodoc:
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end

  def self.init_options(defaults, model, attr)
    options = defaults.dup
    options[:attr] = attr
    options[:prefix] ||= "formatted_"
    options[:formatted_attr] ||= "#{options[:prefix]}#{attr}"

		# If :as is set, then it must be either a formatter Class, Symbol, or String
		options[:as] = formatter_class_for(options[:as]) unless options[:as].nil?

		# Define :block from a block based on :from and :to if they're both set
		options[:block] = Proc.new do
			def from(value)
				options[:from].call(value)
			end

			def to(str)
				options[:to].call(str)
			end
		end unless options[:from].nil? or options[:to].nil?

		# Define the :as from a :block if :block is defined
		options[:as] = define_formatter(attr, &options[:block]) unless options[:block].nil?

		# If :as is still not defined raise an error
 		raise 'No formatting options have been defined.' if options[:as].nil?

		# Instantiate the formatter for this attribute
		options[:formatter] = options[:as].new

    options
  end

	# Define a formatter like the actual physical classes
	# this could easily be done with text similar to the exact
	# layout of the format classes, but this should be faster.
	def self.define_formatter(attr, &formatter)
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
	# the name of a formatter class.  If it's a symbol, check the Formatters
	# module for the class that matches the camelized name of the symbol
	# with 'Format' prepended.
	def self.formatter_class_for(type_name)
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
	
  # The ModelFormatter module allows you to easily handle fields that need to be formatted or stripped
	# of formatting as the are set or retrieved from the database. You can designate one or more of your
	# columns as "formatted columns" like in this example:
  #
  #		class Widget < ActiveRecord::Base
	#			# Set an integer field as a symbol
	#     format :some_integer, :as => :integer
	#
	#     # Specify the type as a class
  #     format :sales_tax, :as => Formatters::FormatCurrency
	#
	#     # Change the prefix of the generated methods and specify type as a symbol
  #     format :sales_tax, :prefix => 'fmt_', :as => :currency
	#
	#     # Use specific procedures to convert the data +from+ and +to+ the target
  #     format :area, :from => Proc.new {|field| number_with_delimiter sprintf('%2d', field)},
  #                   :to => Proc.new {|str| str.gsub(/,/, '')}
	#
	#     # Use a block to define the formatter methods
  #     format :sales_tax do
  #       def from(field)
  #         number_to_currency field
  #       end
  #       def to(str)
  #         str.gsub(/[\$,]/, '')
  #       end
  #     end
	#
	#     ...
	#
  #		end
  #
  # The methods of this module are automatically included into <tt>ActiveRecord::Base</tt>
  # as class methods, so that you can use them in your models.
  #
  # == Generated Methods
  #
  # After calling "<tt>format :sales_tax</tt>" as in the example above, a number of instance methods
  # will automatically be generated, all prefixed by "formatted_" unless :prefix or :formatter_attr
  # have been set:
  #
  # * <tt>Widget#formatted_sales_tax=(value)</tt>: This will set the <tt>sales_tax</tt> of the widget using
	# 	the value stripped of its formatting.
  # * <tt>Widget#formatted_sales_tax</tt>: This will return the <tt>sales_tax</tt> of the widget using
	# 	the formatter specified in the options to +format+.
	module ClassMethods
    # default options. You can override these with +model_formatter+'s +options+ parameter
    DEFAULT_OPTIONS = {
      :prefix => nil,
      :formatted_attr => nil,
      :as => nil,
      :from => nil,
      :to => nil
    }.freeze

    # handle the +attr+ attribute as a "formatted" column, generating additional methods as explained
    # above. You should pass the attribute's name as a symbol, like this:
    #
    #   format :sale_price
    #
    # You can pass in an options hash that overrides the options
    # in +DEFAULT_OPTIONS+.
    def format(attr, options={}, &fmt_block)
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

			  my_options[:formatter].method(:from).call(value)
      end

			# Define the getter for attr
      define_method my_options[:formatted_attr] + '=' do |value|
		    my_options[:formatter].method(:to).call(value)

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
