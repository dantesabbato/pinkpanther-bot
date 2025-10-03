require_relative "../services/telegram_service"
require_relative "../../config/initializer"

module MessageProcessor
  PRIVATE_PROCESSORS = %w[
    GroupList
    GroupSettings
    GroupTriggerWords
    ValentinesStart
    ValentinesAttract
    ValentinesPrepare
    ValentinesForward
    Matchmaker
    MatchmakerAdd
    Start
  ].freeze

  GROUP_PROCESSORS = %w[
    Triggers
    Ping
    Admins
    Status
    Help
    RatingIncrease
    RatingDecrease
    RandomizeMember
    MarriageList
    MarriageEffect
    MarriageDivorce
    MatchMembers
    Actions
    Start
    Stop
  ].freeze

  def self.call(message)
    type = message["chat"]["type"]
    type = "group" if type == "supergroup"
    processors = type == "group" ? GROUP_PROCESSORS : PRIVATE_PROCESSORS

    chat = type == "group" ? Group.find_by(telegram_id: message["chat"]["id"]) : Private.find_by(id: message["chat"]["id"])
    user = User.find_by(id: message["from"]["id"])
    member = type == "group" ? Member.find_by(group:, user:) : nil

    process_result = nil
    processors.each do |processor|
      Initializer.get_logger.debug processor
      klass = "MessageProcessor::#{type.capitalize}::#{processor}".constantize.new(message, TelegramService.bot_api, user, chat, member)
      process_result = klass.process
      break if process_result.present?
    end

    process_result&.each do |item|
      item.each do |command, parameters|
        parameters[:reply_markup] = parameters[:reply_markup].to_json if parameters[:reply_markup].is_a?(Hash)
        parameters[:parse_mode] ||= "HTML" if command.to_s == "send_message"
        PayloadWorker.perform_async(command.to_s, parameters.to_h.deep_stringify_keys)
      end
    end
  end
end