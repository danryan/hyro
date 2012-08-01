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
        connection.put( "#{configuration.base_path}/#{id}", attributes )
      else
        connection.post( "#{configuration.base_path}", attributes )
      end
      
      # load responses data
      begin
        load_attributes(resp.body[configuration.root_name])
      rescue NoMethodError => e
        raise(Hyro::UnknownAttribute, e.message)
      end
      
      @is_persisted = true
      @previously_changed = changes
      @changed_attributes.clear
      
      self
    end
    
    def update
      @previously_changed = changes
      @changed_attributes.clear
      # Do update!
    end
    
  end
end
