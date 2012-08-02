module Hyro
  class Auth < ::Faraday::Middleware
    def call(env)
      env[:request_headers]['Authorization'] ||= "#{@type} #{@token}"
      @app.call(env)
    end
    
    def initialize(app, options = nil)
      super(app)
      options = {} unless Hash===options
      @type, @token = options[:type], options[:token]
      raise Hyro::Misconfigured, "Auth :type can't be nil" if @type.nil?
      raise Hyro::Misconfigured, "Auth :token can't be nil" if @token.nil?
    end
  end
end

Faraday.register_middleware :request, :authorize => Hyro::Auth
