module MessageProcessor::Group
  class Stop
    include ProcessorGroup
    include CommandParameters

    def responds?
      super &&
        (message_from_creator? || message_from_su?) &&
        (command == "stop" || I18n.t("bot.stop.commands_with_anchor").include?(first_parameter))
    end

    def process!
      @chat.disable!
      [{ send_message: { chat_id:, text: I18n.t("bot.stop.text", user: user.link) } }]
    end
  end
end