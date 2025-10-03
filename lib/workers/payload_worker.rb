require_relative "../../config/initializer"

class PayloadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(command, parameters)
    logger = Initializer.get_logger
    logger.debug "PayloadWorker received command: #{command.inspect}"
    logger.debug "PayloadWorker received parameters: #{parameters.inspect}"
    begin
      TelegramService.send(command.to_sym, parameters)
    rescue Telegram::Bot::Exceptions::ResponseError => e
      if e.error_code == 429
        retry_after = e.parameters['retry_after'] || 10
        logger.warn "Rate limit exceeded on #{command}. Retrying after #{retry_after} seconds..."
        sleep retry_after
        retry
      else
        logger.error "Telegram API error on #{command}: #{e.message}"
        logger.error e.backtrace.join("\n")
        raise
      end
    end
  end
end