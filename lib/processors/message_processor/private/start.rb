module MessageProcessor::Private
  class Start
    include ProcessorPrivate

    def responds?
      command == "start"
    end

    def process
      [{
        send_message: {
          chat_id: @message["chat"]["id"],
          text: I18n.t("bot.greeting.text", user: user.full_name),
          reply_markup: {
            inline_keyboard: admin_groups_button + [
              [{ text: I18n.t("bot.greeting.buttons.channel"), url: channel_url }],
              [{ text: I18n.t("bot.greeting.buttons.add"), url: "https://t.me/#{bot_username}?startgroup=true" }]
            ]
          }
        }
      }]
    end

    def admin_groups_button
      user.admin_groups.any? ? [[{ text: I18n.t("bot.greeting.buttons.admin_groups"), callback_data: "group_list" }]] : []
    end
  end
end