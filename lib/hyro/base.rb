module Hyro
  class Base
    
    def self.configure(&block)
      yield configuration
    end
    
    def self.configuration
      @configuration ||= Configuration.new
    end
    
    def self.new_connection
      raise(Misconfigured, "A base_url is required") unless configuration.base_url
      Faraday.new(configuration.base_url) do |conn|
        conn.headers["Accept"] = "application/json"
        conn.request :json
        #conn.response :errorify # custom error handler that raises exceptions
        conn.response :json, :content_type => /\bjson\Z/
        conn.adapter Faraday.default_adapter
      end
    end
    
  end
end
