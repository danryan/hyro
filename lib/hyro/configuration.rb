module Hyro
  class Configuration
    attr_accessor :base_url # http://your.site.com
    attr_accessor :base_path # /widgets or /admin/widgets
    attr_accessor :authorization # "Bearer SEKRETTOKEN"
  end
end
