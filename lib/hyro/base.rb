module Hyro
  class Base
    extend Hyro::Finders
    include Hyro::Persistence
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    
    def initialize(attrs)
      load_attributes(attrs)
    end
    
    def load_attributes(attrs)
      attrs.each do |k,v|
        send("#{k}=", v)
      end
    end
    
    def attributes
      @attributes ||= {}
    end
    
    def self.configure(&block)
      yield configuration
    end
    
    def self.configuration
      @configuration ||= Configuration.new
    end
    
    def configuration
      self.class.configuration
    end
    
    def self.connection
      @connection ||= new_connection
    end
    
    def connection
      self.class.connection
    end
    
    def self.new_connection
      raise(Misconfigured, "A base_url is required") unless configuration.base_url
      raise(Misconfigured, "A root_name is required") unless configuration.root_name
      raise(Misconfigured, "A root_name_plural is required") unless configuration.root_name_plural
      Faraday.new(configuration.base_url) do |conn|
        conn.headers["Accept"] = "application/json"
        conn.request :json
        #conn.response :errorify # custom error handler that raises exceptions
        conn.response :json, :content_type => /\bjson\Z/
        conn.adapter Faraday.default_adapter
      end
    end
    
    # Pass one or more names to define the remote objects properties.
    def self.model_attribute(*attrs)
      define_attribute_methods attrs
      
      attrs.each do |attr|
        define_method(attr) do
          attributes[attr.to_s]
        end
        
        define_method("#{attr}=") do |val|
          send("#{attr}_will_change!") if 
            @previous_attributes && val != @previous_attributes[attr]
          attributes[attr.to_s] = val
        end
      end
    end
    
  end
end
