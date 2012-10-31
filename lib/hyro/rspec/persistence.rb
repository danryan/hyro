module Hyro
  module RSpec
    module Persistence

      mattr_accessor :example
      
      def persisted?
        !!@is_persisted
      end
      
      def save
        save!
        true
      rescue Hyro::Error
        false
      end
      
      def save!
        example.accept = "application/json"

        resp = if persisted?
                 example.put( "#{configuration.base_path}/#{id}", attributes_to_remote )
               else
                 example.post( "#{configuration.base_path}", attributes_to_remote )
               end

        load_attributes_from_remote(JSON.parse(example.response.body))
        @is_persisted = true
        @previously_changed = changes
        @changed_attributes.clear
        errors.clear
        self
        
      rescue Hyro::ValidationFailed => e
        load_attributes_from_remote(e.response.body)
        self
      end
      
    end
  end
end
