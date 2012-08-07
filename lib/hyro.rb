# Hy-speed Remote Objects!
#
# A remote HTTP/JSON resource client built with Faraday & ActiveModel, inspired by ActiveResource.
#
module Hyro
  
  class Error < StandardError; end
  class Misconfigured < Error; end
  class UnknownAttribute < Error; end
  class EmptyResponse < Error; end
  class UnexpectedContentType < Error; end
  class HttpError < Error
    attr_accessor :response
    def initialize(resp, *args)
      @response = resp
      super(*args)
    end
  end
  class Redirected < HttpError; end
  class RequestError < HttpError; end
  class ResourceNotFound < RequestError; end
  class NotAuthorized < RequestError; end
  class PermissionDenied < RequestError; end
  class ValidationFailed < RequestError; end
  class ClientError < HttpError; end
  class ServerError < HttpError; end
  
end

require 'faraday'
require 'faraday_middleware'
require 'json'
require 'active_model'

require "hyro/version"
require 'hyro/transform/time'
require 'hyro/configuration'
require 'hyro/logging'
require 'hyro/auth'
require 'hyro/errors'
require 'hyro/finders'
require 'hyro/persistence'
require 'hyro/actions'
require 'hyro/base'
