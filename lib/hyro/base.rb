module Hyro
  class Base
    extend Hyro::Finders
    include Hyro::Persistence
    include Hyro::Actions
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    
    def initialize(attrs)
      @previous_attributes = {}
      load_attributes(attrs)
    end
    
    def load_attributes(attrs)
      attrs.each do |k,v|
        raise(Hyro::UnknownAttribute, "'#{k}' is not a known attribute") unless respond_to?("#{k}=")
        has_transform = Hash===configuration.transforms && configuration.transforms[k]
        attributes[k.to_s] = has_transform ? configuration.transforms[k].decode(v) : v
      end
    end
    
    def attributes
      @attributes ||= {}
    end
    
    def encoded_attributes
      encoded = {}
      attributes.each do |k,v|
        has_transform = Hash===configuration.transforms && configuration.transforms[k]
        encoded[k.to_s] = has_transform ? configuration.transforms[k].encode(v) : v
      end
      encoded
    end
    
    # .new + #save
    def self.create(*args)
      new(*args).save
    end
    
    # .new + #save!
    def self.create!(*args)
      new(*args).save!
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
        conn.request :authorize, :type => configuration.auth_type, :token => configuration.auth_token
        conn.response :raise_errors
        conn.response :json, :content_type => /\bjson\Z/
        conn.adapter Faraday.default_adapter
      end
    end
    
    def self.assert_valid_response!(resp)
      raise(Hyro::EmptyResponse, "No body received from remote server") unless resp.body
      raise(Hyro::UnexpectedContentType, "Response did not provide an acceptable 'Content-Type' header") unless Hash===resp.body
    end
    
    def assert_valid_response!(*args)
      self.class.assert_valid_response!(*args)
    end
    
    # Pass one or more names to define the remote objects properties.
    def self.model_attribute(*attrs)
      define_attribute_methods attrs
      
      attrs.each do |attr|
        define_method(attr) do
          attributes[attr.to_s]
        end
        
        define_method("#{attr}=") do |val|
          send("#{attr}_will_change!") if val != @previous_attributes[attr]
          attributes[attr.to_s] = val
        end
      end
    end
    
  end
end
