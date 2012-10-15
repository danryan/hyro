module Hyro
  class Base
    extend Hyro::Finders
    include Hyro::Persistence
    include Hyro::Actions
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    
    attr_reader :errors
    
    def initialize(attrs=nil)
      @errors = ActiveModel::Errors.new(self)
      @previous_attributes = {}
      load_attributes(attrs)
    end
    
    def to_param
      raise(Hyro::Misconfigured, "An 'id' attribute is required.") unless respond_to?(:id)
      id.to_s
    end
    
    def to_s
      "<#{self.class} #{attributes.map {|k,v| "#{k}=#{v.inspect}"}*' ' }>"
    end
    
    # Populate this instance with the given attribute values & errors.
    #
    # Does not perform transformations. Instead use `*_from_remote` methods when loading data from the remote service.
    #
    def load_attributes(attrs=nil)
      return unless attrs
      if (errs = attrs.delete('errors')) && !errs.empty?
        errs.each do |e_attr, e_descs|
          e_descs.each do |e_desc|
            errors.add(e_attr, e_desc)
          end
        end
        return # keep the local state intact when validation errors are received
      end
      attrs.each do |k,v|
        raise(Hyro::UnknownAttribute, "'#{k}' is not a known attribute") unless respond_to?("#{k}=")
        attributes[k.to_s] = v
      end
    end
    
    # Instantiate an existing remote object, such as the result of a find, with the given attributes.
    #
    # Performs sanity checks & transformations.
    #
    def self.existing_from_remote(attrs=nil)
      inst = new
      inst.load_attributes(attributes_from_remote(attrs))
      inst.instance_variable_set(:@is_persisted, true)
      inst
    end
    
    # Populate the instance with attributes returned from the remote service.
    #
    # Performs sanity checks & transformations.
    #
    def load_attributes_from_remote(attrs=nil)
      load_attributes(attributes_from_remote(attrs))
    end
    
    # Hash of the instance's attributes. DO NOT ACCESS THESE DIRECTLY.
    #
    # Instead, use the getter & setter methods defined by Hyro::Base.model_attribute.
    #
    def attributes
      @attributes ||= {}
    end
    
    # Hash of the instance's attributes, encoded by any `configuration.transforms`.
    #
    def encoded_attributes
      encoded = {}
      attributes.each do |k,v|
        has_transform = Hash===configuration.transforms && configuration.transforms[k]
        encoded[k.to_s] = has_transform ? configuration.transforms[k].encode(v) : v
      end
      encoded
    end
    
    # Returns a hash of encoded attributes formatted with the optional/configured root element.
    #
    # Options include:
    #   * :include_root for a single root-element using the configured root name
    #
    def attributes_to_remote(options=nil)
      options = {} unless Hash===options
      if options[:include_root] || configuration.include_root
        {configuration.root_name => encoded_attributes}
      else
        encoded_attributes
      end
    end
    
    # Hash of attributes, decoded by any `configuration.transforms`.
    #
    def self.decoded_attributes(attrs)
      decoded = {}
      attrs.each do |k,v|
        has_transform = Hash===configuration.transforms && configuration.transforms[k]
        decoded[k.to_s] = has_transform ? configuration.transforms[k].decode(v) : v
      end
      decoded
    end
    
    # Returns a hash of decoded attributes accessed with the optional/configured root element.
    #
    # Options include:
    #   * :include_root for a single root-element using the configured root name
    #
    def self.attributes_from_remote(attrs, options=nil)
      return unless attrs
      assert_valid_response!(attrs)
      options = {} unless Hash===options
      if options[:include_root] || configuration.include_root
        decoded_attributes(attrs[configuration.root_name])
      else
        decoded_attributes(attrs)
      end
    end
    
    # See equivalent class method Hyro::Base.attributes_from_remote
    #
    def attributes_from_remote(*args)
      self.class.attributes_from_remote(*args)
    end
    
    # .new + #save
    def self.create(*args)
      new(*args).save
    end
    
    # .new + #save!
    def self.create!(*args)
      new(*args).save!
    end
    
    # Call with a block accepting the configuration, to set-up the class.
    #
    #     class Thing < Hyro::Base
    #       configure do |conf|
    #         conf.root_name = "thing"
    #       end
    #     end
    #
    def self.configure(&block)
      r = yield(configuration)
      configuration.include_root = true if configuration.include_root.nil? 
      r
    end
    
    def self.configuration
      @configuration ||= Configuration.new
    end
    
    def configuration
      self.class.configuration
    end
    
    # The underlying Faraday transport.
    #
    def self.connection
      @connection ||= new_connection
    end
    
    # The underlying Faraday transport; one per class.
    #
    def connection
      self.class.connection
    end
    
    def self.new_connection
      raise(Misconfigured, "A base_url is required") unless configuration.base_url
      raise(Misconfigured, "A root_name is required") unless configuration.root_name
      raise(Misconfigured, "A root_name_plural is required") unless configuration.root_name_plural
      Faraday.new(configuration.base_url) do |conn|
        conn.use :instrumentation
        conn.headers["Accept"] = "application/json"
        conn.request :json
        if configuration.auth_type && configuration.auth_token
          conn.request :authorize, :type => configuration.auth_type, :token => configuration.auth_token
        end
        conn.response :raise_errors
        conn.response :json, :content_type => /\bjson\Z/
        conn.adapter Faraday.default_adapter
      end
    end
    
    def self.assert_valid_response!(response_body)
      # When the Content-Type is recognized by Faraday, the body is coerced into a Hash.
      raise(Hyro::UnexpectedContentType, "Response did not provide an acceptable 'Content-Type' header") unless 
        Hash===response_body
    end
    
    def assert_valid_response!(*args)
      self.class.assert_valid_response!(*args)
    end
    
    # Pass one or more names to define the remote objects properties.
    #
    #     class Thing < Hyro::Base
    #       model_attribute :id, :name, :created_at, :updated_at
    #     end
    #
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
