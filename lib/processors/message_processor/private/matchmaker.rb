module MessageProcessor::Private
  class Matchmaker
    include ProcessorPrivate

    def responds?
      message_from_su? && message_text == "matchmaker"
    end

    def process!
      groups = Group.all_enabled
      inline_keyboard = groups.map { |group| [{ text: group.title, callback_data: "matchmaker:#{group.id}" }] }
      [{ send_message: { chat_id:, text: I18n.t("groups.text.many"), reply_markup: { inline_keyboard: } } }]
    end
  end
end