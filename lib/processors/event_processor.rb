require_relative "../services/telegram_service"
require_relative "../../config/initializer"

module EventProcessor
  EVENT_PROCESSORS = %w[
    Added
    Kicked
  ].freeze

  def self.call(update, type)
    Initializer.get_logger.debug "EventProcessor received update: #{update.inspect}"
    process_result = nil
    type = "group" if type == "supergroup"
    EVENT_PROCESSORS.each do |processor|
      klass = "EventProcessor::#{type.capitalize}::#{processor}".constantize.new(update, TelegramService.bot_api)
      process_result = klass.process if process_result.nil?
    end
    return if process_result.blank?
    process_result.each do |item|
      item.each do |command, parameters|
        parameters[:reply_markup] = parameters[:reply_markup].to_json if parameters[:reply_markup].is_a?(Hash)
        parameters[:parse_mode] ||= "HTML" if command.to_s == "send_message"
        PayloadWorker.perform_async(command.to_s, parameters.to_h.deep_stringify_keys)
      end
    end
  end
end