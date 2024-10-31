module Fibernetics
  class ResponseParser
    def parse(raw_response)
      response_status = raw_response.fetch("OK")

      raise(Errors::ResponseError.new) unless response_status

      raw_response
    end
  end
end
