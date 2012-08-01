# Hy-speed Remote Objects!
#
# A remote HTTP/JSON resource client built with Faraday & ActiveModel, inspired by ActiveResource.
#
module Hyro
  
  class Error < StandardError; end
  class Misconfigured < Error; end
  
end

require 'faraday'
require 'faraday_middleware'
require 'active_model'

require "hyro/version"
require 'hyro/configuration'
require 'hyro/base'
