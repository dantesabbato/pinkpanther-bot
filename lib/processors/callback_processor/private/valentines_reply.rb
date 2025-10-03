module CallbackProcessor::Private
  class ValentinesReply
    include ProcessorPrivate

    def responds?
      callback_data[0] == "valentines_answer"
    end

    def process!
      valentine = Valentine.find_or_create_by(sender_id: user.id, recipient_id: callback_data[1], status: "pending")
      [{
        send_message: {
          chat_id: user.id,
          text: I18n.t("valentines.send.text", user: valentine.recipient.link),
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