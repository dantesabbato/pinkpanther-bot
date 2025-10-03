module EventProcessor::Group
  class Kicked
    include ProcessorGroup

    def responds?
      @message["left_chat_member"] &&
        @message["left_chat_member"]["id"] == bot_id &&
        @message["from"]["id"] != bot_id &&
        !message_from_su?
    end

    def process!
      @chat.disable!
      [
        {
          send_message: {
            chat_id: @user.id,
            text: I18n.t("bot.kicked.message_from_developers", group: @chat.title)
          }
        },
        {
          send_message: {
            chat_id: su_id,
            text: I18n.t("bot.kicked.notification", group: @chat.title, user: @user.link)
          }
        }
      ]
    end
  end
end