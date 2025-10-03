module MessageProcessor::Group
  class Start
    include ProcessorGroup
    include CommandParameters

    def responds?
      message_from_admin? && command == "start"
    end

    def process!
      if message_from_su? && !@chat.enabled
        @chat.enable!
        results = [{ send_message: { chat_id:, text: I18n.t("bot.enabled.text") } }]
        results << { delete_message: { chat_id:, message_id: } } if can_delete_messages?
      end
    end
  end
end