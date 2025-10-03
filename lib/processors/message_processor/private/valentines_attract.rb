module MessageProcessor::Private
  class ValentinesAttract
    include Processor

    def responds?
      command == "valentines_attract"
    end

    def process!
      groups = message_from_su? ? Group.all_enabled : Group.admin_groups(user.id)
      messages = groups&.flat_map { |group| message(group.telegram_id) } || []
      messages << {
        send_message: {
          chat_id: user.id,
          text: I18n.t("valentines.attraction.text_#{messages.any? ? 'done' : 'failed'}")
        }
      }
      messages
    end

    private

    def message(chat_id)
      [
        {
          send_photo: { chat_id: chat_id, photo:  (I18n.t"valentines.attraction.pics").sample }
        },
        {
          send_message: {
            chat_id: chat_id,
            text: (I18n.t 'valentines.attraction.text').sample,
            reply_markup: {
              inline_keyboard: [[{
                text: I18n.t("valentines.attraction.button"),
                url: bot_url("valentines")
              }]]
            }
          }
        }
      ]
    end
  end
end