module Hyro
  # Non-REST HTTP methods, i.e. /order, /copy, etc.
  module Actions
    
    # Member actions.
    #
    def action(name, params=nil)
      raise(Hyro::Misconfigured, "actions configuration is required, instead "+
        "got #{configuration.actions.inspect}") unless 
          Hash===configuration.actions
      raise(Hyro::Misconfigured, "action is missing from configuration, have member "+
        "actions #{configuration.actions['member'].inspect}") unless
          configuration.actions['member'] && configuration.actions['member'][name]
      
      http_method = configuration.actions['member'][name]
      params = Hash===params ? params : {}
      
      # Send current attributes too, when saving.
      params = (http_method=='put' || http_method=='post' ? params.merge(attributes_to_remote) : params)
      
      resp = connection.send(http_method, action_base_url(name), params)
      load_attributes_from_remote(resp.body)
      errors.clear
      self
      
    rescue Hyro::ValidationFailed => e
      load_attributes_from_remote(e.response.body)
      self
    end

    def member_base_url
      "#{configuration.base_path}/#{id}"
    end

    def action_base_url(name)
      "#{member_base_url}/#{name}"
    end
  end
end
