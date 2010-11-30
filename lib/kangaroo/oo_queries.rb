module Kangaroo
  module OoQueries
    OPERATORS = (%w(= != > >= < <= ilike like in child_of parent_left parent_right) + ['not in']).join("|").freeze
    CONDITION_PATTERN = /\A(.*)\s+(#{OPERATORS})\s+(.*)\Z/i.freeze
    
    def self.included base
      base.extend ClassMethods
    end
    
    
    module ClassMethods
      def search query_parameters = {}
        conditions = query_parameters[:conditions] || []
        conditions = conditions.sum([]) {|c| convert_condition(c) }
        
        args = [conditions, 0]
        args[1] = query_parameters[:offset] if query_parameters[:offset]
        args << query_parameters[:limit] if query_parameters[:limit]
        
        database(query_parameters[:db_name]).search(self, *args)
      end
      
      def read ids, column_names = nil
        options = ids.extract_options!
                
        database = database(options[:db_name])
        database.read(self, ids, column_names).map do |record|
          instantiate(record).tap do |r|
            r.database = database
          end
        end
      end
      
      def default_get *fields
        options = fields.extract_options!
        
        database(options[:db_name]).default_get(self, fields)
      end
      
      protected      
      def convert_condition condition
        case condition
        when Hash
          [].tap do |arr|
            condition.each do |key, value|
              op = value.is_a?(Array) ? 'in' : '='
              arr << [key, op, value]
            end
          end
        when String
          [CONDITION_PATTERN.match(condition).captures]
        when Array
          #TODO
        end
      end
    end
  end
end