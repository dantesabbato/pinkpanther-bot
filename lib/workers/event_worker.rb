require_relative "../../config/initializer"
require_relative "../services/telegram_service"

class EventWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(event, type)
    Initializer.get_logger.debug "EventWorker received event: #{event.inspect}"
    begin
      EventProcessor.call(event, type["name"])
    rescue => e
      Initializer.get_logger.error "Error in EventWorker: #{e.message}"
      Initializer.get_logger.error e.backtrace.join("\n")
    end
  end
end