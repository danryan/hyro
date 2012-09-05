module Hyro
  class Configuration
    attr_accessor :root_name # root-element name in singular JSON payload
    attr_accessor :root_name_plural # root-element name in collection JSON payload
    attr_accessor :base_url # http://your.site.com
    attr_accessor :base_path # /widgets or /admin/widgets
    attr_accessor :auth_type # "Bearer"
    attr_accessor :auth_token # "SEKRETTOKEN"
    attr_accessor :actions # a nested hash of scope (collection|member|new) => action names => HTTP method
    attr_accessor :transforms # a hash of attributes names => transformer classes which define :encode & :decode
  end
end
