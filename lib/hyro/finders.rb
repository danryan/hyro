module Hyro
  module Finders
    
    # Fetch the remote resource(s)
    #
    # Returns nil when not found.
    #
    def find(*args)
      find!(*args)
    rescue Hyro::ResourceNotFound
    end
    
    # Imperative find raises an exception when not found.
    #
    def find!(*args)
      if String===args[0] or Integer===args[0]
        find_by_id(*args)
      else
        find_by_query(*args)
      end
    end
    
    def find_by_id(*args)
      params = Hash===args[1] ? args[1] : {}
      resp = connection.get( url_for_find_by_id(*args), params )
      existing_from_remote(resp.body)
    end

    def url_for_find_by_id(*args)
      "#{configuration.base_path}/#{args[0]}"
    end

    def find_by_query(*args)
      params = Hash===args[0] ? args[0] : {}
      resp = connection.get( url_for_find_by_query(*args), params )
      existing_collection_from_remote(resp.body)
    end

    def url_for_find_by_query(*args)
      configuration.base_path
    end
    
  end
end
