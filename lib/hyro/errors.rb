module Hyro
  class Errors < ::Faraday::Response::Middleware
    def call(env)
      res = @app.call(env)
      case res.status
      when (200...300)
        res
      when (401)
        raise Hyro::NotAuthorized.new(res)
      when (403)
        raise Hyro::PermissionDenied.new(res)
      when (404)
        raise Hyro::ResourceNotFound.new(res)
      when (422)
        raise Hyro::ValidationFailed.new(res)
      when (300...400)
        raise Hyro::Redirected.new(res)
      when (400...500)
        raise Hyro::RequestError.new(res)
      when (500...600)
        raise Hyro::ServerError.new(res)
      else
        raise Hyro::ServerError.new(res)
      end
      res
    end
  end
end

Faraday.register_middleware :response, :raise_errors => Hyro::Errors
