require 'kangaroo/util/database_proxy'

module Kangaroo
  module Util
    class Database
      attr_accessor :db_name, :user, :password, :user_id, :client, :models
    
      def initialize client, name, user, password, user_id = nil
        @client, @db_name, @user, @user_id, @password = client, name, user, user_id, password
      
        @models = []
      end
      
      delegate :db, :to => :client
      
      def common
        @common_proxy ||= CommonProxy.new client.common_service, db_name, user_id, password
      end

      def object
        @object_proxy ||= ObjectProxy.new client.object_service, db_name, user_id, password
      end
      
      def wizard
        @wizard_proxy ||= WizardProxy.new client.wizard_service
      end
      
      def report
        @report_proxy ||= ReportProxy.new client.report_service
      end
    
      def logged_in?
        !!user_id
      end
    
      def login!
        @user_id = common_proxy.login db_name, user, password
      
        true
      end
    
      def login
        login! unless logged_in?
      rescue
        false
      end
    
      # DISCUSS doesn't belong here
      def load_models model_names = ['*']
        login!
        model_names = model_names.map do |name|
          replace_wildcard name
        end
      
        models_to_load = model_names.sum([]) do |m|
          Oo::Ir::Model.where("model ilike #{m}").all
        end
      
        models_to_load = models_to_load.sort_by do |m|
          m.model.length
        end      
      
        create_models models_to_load
      end
    
      protected
      def replace_wildcard string
        string.gsub '*', '%'
      end
      
      def create_models models_to_load
        @models += models_to_load
      
        models_to_load.map do |model|
          model.create_class
        end      
      end
    end
  end
end