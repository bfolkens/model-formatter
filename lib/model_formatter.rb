module ModelFormatter # :nodoc:
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end

  def self.init_options(defaults, model, attr)
    options = defaults.dup
    options[:attr] = attr
    options[:column_prefix] ||= "formatted_"
    options[:formatted_attr] ||= "#{options[:column_prefix]}#{attr}"
 
 		options[:as] ||= default_formatter_for(attr)
		options[:as] = formatter_class_for(options[:as]) unless options[:as].nil?
		options[:block] ||= options[:as].new unless options[:as].nil?

		options[:from], options[:to] = [options[:block].method(:from),
																		options[:block].method(:to)] if options[:block]

    options
  end

	def self.default_formatter_for(attr)
		formatter_class_for attr.send(:class)
	end

	def self.formatter_class_for(type_name)
		return type_name if type_name.kind_of? Class and type_name.superclass == Formatters::Format

		type_name = type_name.to_s.capitalize if type_name.is_a? Symbol
		formatter_class = const_get('Formatters').const_get("Format#{type_name}")
		raise Formatters::FormatNotFoundException unless formatter_class.superclass == Formatters::Format
	end

	require File.dirname(__FILE__) + '/formatters.rb'
	
  # The ModelFormatter module allows you to easily handle fields that need to be formatted or stripped
	# of formatting as the are set or retrieved from the database. You can designate one or more of your
	# columns as "formatted columns" like in this example:
  #
  #		class Widget < ActiveRecord::Base
	#			# Automatically determine integer type and format to the default
	#     format :some_integer
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
  # will automatically be generated, all prefixed by "formatted_" unless :column_prefix or :formatter_attr
  # have been set:
  #
  # * <tt>Widget#formatted_sales_tax=(value)</tt>: This will set the <tt>sales_tax</tt> of the widget using
	# 	the value stripped of its formatting.
  # * <tt>Widget#formatted_sales_tax</tt>: This will return the <tt>sales_tax</tt> of the widget using
	# 	the formatter specified in the options to +format+.
	module ClassMethods
    # default options. You can override these with +model_formatter+'s +options+ parameter
    DEFAULT_OPTIONS = {
      :column_prefix => nil,
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

      define_method my_options[:formatted_attr] do ||
				# Retrieve the value
				value = method(attr).call

				# Default return the raw value if value is nil
				return value if value.nil?

        # Convert the value
			  self.method(my_options[:from]).call(value)
      end

      define_method my_options[:formatted_attr] + '=' do |value|
        unless value.nil?
          # Convert the value
			    self.method(my_options[:to]).call(value)
			  end

        # Set the attribute vlaue
        self.update_attributes(attr, value)
      end

      # this creates a closure keeping a reference to my_options
      # right now that's the only way we store the options. We
      # might use a class attribute as well
      define_method "#{attr}_options" do
        my_options
      end
    end

  end
end
