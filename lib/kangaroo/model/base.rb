require 'kangaroo/model/relation'
require 'kangaroo/model/attributes'
require 'kangaroo/model/default_attributes'
require 'kangaroo/model/inspector'
require 'kangaroo/model/persistence'
require 'kangaroo/model/open_object_orm'
require 'active_model/callbacks'
require 'active_support/core_ext/class'

module Kangaroo
  module Model
    class Base
      class_attribute :database
      class_inheritable_array :field_names

      extend ActiveModel::Callbacks
      define_model_callbacks :initialize
      define_model_callbacks :find

      include Attributes
      include DefaultAttributes
      include Inspector
      include Persistence
      extend OpenObjectOrm

      attr_reader :id

      # Initialize a new object, and set attributes
      #
      # @param [Hash] attributes
      def initialize attributes = {}
        @attributes = {}

        _run_initialize_callbacks do
          self.attributes = attributes
        end
      end

      # Send method calls via xmlrpc to OpenERP
      #
      def remote
        self.class.remote
      end

      class << self
        # Return this models OpenObject name
        def oo_name
          Oo.ruby_name_to_oo self.name
        end

        # Send method calls via xmlrpc to OpenERP
        #
        def remote
          @remote ||= database.object oo_name
        end
      end
    end
  end
end

# require 'active_support/core_ext/module/delegation'
# require 'active_model'
#
# require 'kangaroo/relation'
# require 'kangaroo/oo_queries'
# require 'kangaroo/queries'
# require 'kangaroo/column'
# require 'kangaroo/attributes'
# require 'kangaroo/execute'
#
# module Kangaroo
#   class Base
#     extend ActiveModel::Naming
#     extend ActiveModel::Callbacks
#     include ActiveModel::Validations
#     include ActiveModel::Dirty
#     include OoQueries
#     include Queries
#     include Attributes
#     include Execute
#
#     class_attribute :columns
#
#     define_model_callbacks :find
#
#
#
#     class << self
#       delegate  :where,
#                 :offset,
#                 :limit,
#                 :select,
#                 :context,
#                 :[],
#                 :to => :relation
#
#       def inspect
#         "".tap do |s|
#           s << self.name << "("
#           s << "id, "
#           s << columns.map {|c| "#{c.name}: #{c.type}"} * ", "
#           s << ")"
#         end
#       end
#
#       def relation default_scope = true
#         if default_scope && @default_scope
#           @relation = send(@default_scope)
#         else
#           @relation = Relation.new self
#         end
#       end
#
#       def default_scope relation_method
#         @default_scope = relation_method
#       end
#
#       def database
#         Kangaroo.database
#       end
#
#       def oo_model_name
#         Oo.ruby_name_to_oo name
#       end
#
#       def instantiate attributes
#         attributes = attributes.stringify_keys
#         allocate.tap do |object|
#           object.instance_variable_set :@attributes, attributes.except('id')
#           object.instance_variable_set :@id, attributes['id']
#           # object.instance_variable_set :@attributes_cache, {}
#
#           object.instance_variable_set :@new_record, false
#           # object.instance_variable_set :@readonly, false
#           # object.instance_variable_set :@destroyed, false
#           # object.instance_variable_set :@marked_for_destruction, false
#           # object.instance_variable_set :@previously_changed, {}
#           # object.instance_variable_set :@changed_attributes, {}
#
#           object.send :_run_find_callbacks
#           object.send :_run_initialize_callbacks
#         end
#       end
#     end
#   end
# end