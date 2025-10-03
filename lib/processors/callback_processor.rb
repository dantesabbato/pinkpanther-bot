require_relative "../services/telegram_service"
require_relative "../../config/initializer"

module CallbackProcessor
  GROUP_PROCESSORS = %w[
    MarriageEffect
  ]

  PRIVATE_PROCESSORS = %w[
    GroupAction
    GroupList
    GroupSettings
    GroupTriggers
    GroupTriggerWords
    MemberAction
    Matchmaker
    ValentinesShare
    ValentinesCancel
    ValentinesReply
    Complete
  ].freeze

  def self.call(update, type)
    Initializer.get_logger.debug "CallbackProcessor received query: #{update.inspect} and #{type.inspect}"
    process_result = nil
    type = "group" if type == "supergroup"
    processors = type == "group" ? GROUP_PROCESSORS : PRIVATE_PROCESSORS
    processors.each do |processor|
      Initializer.get_logger.debug processor
      klass = "CallbackProcessor::#{type.capitalize}::#{processor}".constantize.new(update, TelegramService.bot_api)
      process_result = klass.process if process_result.nil?
    end
    return if process_result.blank?
    process_result.each do |item|
      item.each do |command, parameters|
        parameters[:reply_markup] = parameters[:reply_markup].to_json if parameters[:reply_markup].is_a?(Hash)
        parameters[:parse_mode] ||= "HTML" if command.to_s == "send_message" || command.to_s == "edit_message_text"
        PayloadWorker.perform_async(command.to_s, parameters.to_h.deep_stringify_keys)
      end
    end
  end
end