module Hyro
  module RSpec
    # Non-REST HTTP methods, i.e. /order, /copy, etc.
    module Actions

      def example
        Hyro::RSpec.example
      end

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

        example.accept = "application/json"
        resp = example.send(http_method, "#{configuration.base_path}/#{to_param}/#{name}", params)
        Hyro::Errors.check_status( example.response.code.to_i, example.response )

        load_attributes_from_remote( JSON.parse(example.response.body) )
        errors.clear
        self

      rescue Hyro::ValidationFailed => e
        load_attributes_from_remote(e.response.body)
        self
      end
    end
  end
end
