require_relative "../../config/initializer"
require_relative "../services/telegram_service"

class CallbackWorker
  include Sidekiq::Worker
  sidekiq_options queue: :callback, retry: false

  def perform(update, type)
    Initializer.get_logger.debug "CallbackWorker received callback_query: #{update.inspect} and #{type.inspect}"
    begin
      CallbackProcessor.call(update, type["name"])
    rescue => e
      Initializer.get_logger.error "Error in CallbackProcessor: #{e.message}"
      Initializer.get_logger.error e.backtrace.join("\n")
    end
  end
end