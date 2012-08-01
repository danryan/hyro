module Hyro
  class Configuration
    attr_accessor :root_name # root-element name in singular JSON payload
    attr_accessor :root_name_plural # root-element name in collection JSON payload
    attr_accessor :base_url # http://your.site.com
    attr_accessor :base_path # /widgets or /admin/widgets
    attr_accessor :authorization # "Bearer SEKRETTOKEN"
  end
end
