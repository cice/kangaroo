require 'kangaroo/railtie' if defined?(Rails)

require 'kangaroo/util/configurator'

# require 'kangaroo/client'
# require 'kangaroo/database_proxy'
# require 'kangaroo/database'
# require 'kangaroo/base'
# 
# require 'oo'

module Kangaroo
  mattr_accessor :configuration
  
  delegate :database, :configured?, :to => :configuration
end