module MessageProcessor::Private
  class ValentinesPrepare
    include ProcessorPrivate
    include CommandParameters

    def responds?
      valentines_recipient.present?
    end

    def process!
      valentine = Valentine.find_or_create_by(sender_id: user.id, recipient_id: words[1], status: "pending")
      [{
        send_message: {
          chat_id: user.id,
          text: I18n.t("valentines.send.text", user: valentines_recipient.link),
          reply_markup: {
            inline_keyboard: [[{
              text: I18n.t("valentines.send.buttons.cancel"),
              callback_data: "valentines_cancel:#{valentine.id}"
            }]]
          }
        }
      }]
    end
  end
end