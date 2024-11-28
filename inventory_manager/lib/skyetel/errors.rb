module Skyetel
  module Errors
    class UnauthorizedError < StandardError; end
    class ResponseError < StandardError; end
    class DataNotLoadedError < StandardError; end
    class TimeoutError < StandardError; end
  end
end
