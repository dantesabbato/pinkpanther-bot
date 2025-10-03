module CallbackProcessor::Private
  class ValentinesShare
    include ProcessorPrivate

    def responds?
      callback_data[0] == "valentines_share"
    end

    def process!
      group = Group.find_by(id: callback_data[1])
      return unless group&.enabled
      [
        {
          send_message: {
            chat_id: group.telegram_id,
            text: (I18n.t "valentines.shared_link.text", user: user.link).sample,
            reply_markup: { inline_keyboard: [[{ text: I18n.t("valentines.shared_link.button"), url: bot_url(user.id) }]] }
          }
        },
        {
          edit_message_text: {
            chat_id: @message["message"]["chat"]["id"],
            message_id: @message["message"]["message_id"],
            text: I18n.t("valentines.start.text", link: bot_url(user.id), groups: nil),
            reply_markup: nil
          }
        },
        {
          send_message: { chat_id: @message["message"]["chat"]["id"], text: I18n.t("valentines.shared_link.text_sent") }
        }
      ]
    end
  end
end