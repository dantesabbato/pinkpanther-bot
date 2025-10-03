module EventProcessor::Group
  class Added
    include ProcessorGroup

    def responds?
      @message["new_chat_members"]&.any? { |member| member["id"] == bot_id } && @message["chat"]["id"].negative?
    end

    def process!
      [
        {
          send_sticker: { chat_id: @chat.telegram_id, sticker: I18n.t("bot.added.sticker") }
        },
        {
          send_message: {
            chat_id: @chat.telegram_id,
            text: I18n.t("bot.added.text", channel: I18n.t("bot.added.link", url: channel_url))
          }
        },
        {
          send_message: {
            chat_id: su_id,
            text: I18n.t("groups.new.text", group_title: @chat.title),
            reply_markup: {
              inline_keyboard: [[
                { text: I18n.t("groups.new.buttons.accept"), callback_data: "group_action:#{@chat.id}:ok" },
                { text: I18n.t("groups.new.buttons.reject"), callback_data: "group_action:#{@chat.id}" }
              ]]
            }
          }
        }
      ]
    end
  end
end