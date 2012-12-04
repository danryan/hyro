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
        connection.put( save_put_url, attributes_to_remote )
      else
        connection.post( save_post_url, attributes_to_remote )
      end
      
      load_attributes_from_remote(resp.body)
      
      @is_persisted = (200..300).include? resp.status.to_i
      @previously_changed = changes
      @changed_attributes.clear
      errors.clear
      self
      
    rescue Hyro::ValidationFailed => e
      load_attributes_from_remote(e.response.body)
      self
    end

    def save_put_url
      "#{configuration.base_path}/#{id}"
    end

    def save_post_url
      "#{configuration.base_path}"
    end
  end
end
