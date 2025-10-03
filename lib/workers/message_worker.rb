require_relative "../../config/initializer"
require_relative "../services/telegram_service"

class MessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(message)
    Initializer.get_logger.debug "MessageWorker received message: #{message.inspect}"
    begin
      MessageProcessor.call(message)
    rescue => e
      Initializer.get_logger.error "Error in MessageWorker: #{e.message}"
      Initializer.get_logger.error e.backtrace.join("\n")
    end
  end
end