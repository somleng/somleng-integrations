module Skyetel
  class ResponseParser
    def parse(raw_response, **)
      response_code = raw_response.fetch("code")
      error = raw_response.fetch("error")

      raise(Errors::UnauthorizedError.new(error)) if response_code == 401
      raise(Errors::ResponseError.new(error)) unless response_code == 200

      raw_response
    end
  end
end
