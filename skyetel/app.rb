require "logger"
require_relative "config/application"

module App
  class Handler
    attr_reader :event, :context

    def self.process(event:, context:)
      logger = Logger.new($stdout)
      logger.info("## Processing Event")
      logger.info(event)

      new(event:, context:).process
    rescue Exception => e
      Sentry.capture_exception(e)
      raise(e)
    end

    def initialize(event:, context:)
      @event = event
      @context = context
    end

    def process

    end
  end
end
