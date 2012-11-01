module Hyro
  module Persistence
    
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
      resp = if persisted?
        connection.put( "#{configuration.base_path}/#{id}", attributes_to_remote )
      else
        connection.post( "#{configuration.base_path}", attributes_to_remote )
      end
      
      load_attributes_from_remote(resp.body)
      
      @is_persisted = (200..300).include? resp.code.to_i
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
