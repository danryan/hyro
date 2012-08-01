module Hyro
  # Non-REST HTTP methods, i.e. /order, /copy, etc.
  module Actions
    
    # Member actions
    def action(name, params=nil)
      raise(Hyro::Misconfigured, "actions configuration is required, instead "+
        "got #{configuration.actions.inspect}") unless 
          Hash===configuration.actions
      raise(Hyro::Misconfigured, "action is missing from configuration, have member "+
        "actions #{configuration.actions['member'].inspect}") unless
          configuration.actions['member'] && configuration.actions['member'][name]
      
      http_method = configuration.actions['member'][name]
      params = Hash===params ? params : {}
      
      resp = connection.send(http_method, "#{configuration.base_path}/#{id}/#{name}", params)
      load_attributes(resp.body[configuration.root_name])
      
      self
    end
    
  end
end
