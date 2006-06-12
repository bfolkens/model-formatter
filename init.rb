# plugin init file for rails
# this file will be picked up by rails automatically and
# add the model_formatter extensions to rails
#
# code based on file_column by sebastian.kanthak@muehlheim.de

require 'model_formatter'

ActiveRecord::Base.send(:include, ModelFormatter)

