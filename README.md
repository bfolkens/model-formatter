## Overview

The ModelFormatter module allows you to easily handle fields that need to be formatted or stripped
of formatting as they are set or retrieved from the database. You can designate one or more of your
columns as "formatted columns" like in this example:

    class Widget < ActiveRecord::Base
      # Set an integer field as a symbol
      format_column :some_integer, :as => :integer

      # Specify the type as a class
      format_column :sales_tax, :as => Formatters::FormatCurrency
      format_column :sales_tax, :as => Formatters::FormatCurrency.new(:precision => 4)

      # Change the prefix of the generated methods and specify type as a symbol
      format_column :sales_tax, :prefix => 'fmt_', :as => :currency, :options => {:precision => 4}

      # Use specific procedures to convert the data +from+ and +to+ the target
      format_column :area, :from => Proc.new {|value, options| number_with_delimiter sprintf('%2d', value)},
                           :to => Proc.new {|str, options| str.gsub(/,/, '')}

      # Use a block to define the formatter methods
      format_column :sales_tax do
        def from(value, options = {})
          number_to_currency value
        end
        def to(str, options = {})
          str.gsub(/[\$,]/, '')
        end
      end

      ...
    end

The methods of this module are automatically included into `ActiveRecord::Base`
as class methods, so that you can use them in your models.


## Documentation

For more detailed documentation, create the rdocs with the following command:

    rake rdoc


## Running Unit Tests

By default, the ModelFormatter plugin uses the mysql +test+ database, running on +localhost+.  To run the tests, enter the following:

    rake


## Bugs & Feedback

Please file a bug report at http://github.com/bfolkens/model-formatter/issues

[![Build Status](https://secure.travis-ci.org/bfolkens/model-formatter.png)](http://travis-ci.org/bfolkens/model-formatter)

## Credits

Sebastian Kanthak's file_column plugin - used for ideas and best practices.

