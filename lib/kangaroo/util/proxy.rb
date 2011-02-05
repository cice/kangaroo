require 'rapuncel'

module Kangaroo
  module Util
    class Proxy < Rapuncel::Proxy
      def __initialize__ client, *curry_args
        @curry_args = curry_args
      end
      
      def call! name, *args
        super name, __curry__(*args)
      end
      
      protected
      def __curry__ *args
        curry_args + args
      end
    end
    
    autoload :CommonProxy, 'kangaroo/util/common_proxy'
    autoload :DbProxy, 'kangaroo/util/db_proxy'
        # 
        # class DbProxy < Proxy
        #   # Create a new OpenERP database
        #   def create db_name
        #     call! :create, *args
        #   end
        # end
  end
end