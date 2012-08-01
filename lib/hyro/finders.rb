module Hyro
  module Finders
    
    def find(*args)
      if String===args[0] or Integer===args[0]
        find_by_id(*args)
      else
        raise(Error, "Finder not defined for args #{args.inspect}")
      end
    end
    
    def find_by_id(*args)
      params = Hash===args[1] ? args[1] : {}
      resp = connection.get( "#{configuration.base_path}/#{args[0]}", params )
      inst = new(resp.body[configuration.root_name])
      inst.instance_variable_set(:@is_persisted, true)
      inst
    end
    
  end
end
