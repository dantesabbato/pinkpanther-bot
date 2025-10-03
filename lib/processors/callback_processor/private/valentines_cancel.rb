module CallbackProcessor::Private
  class ValentinesCancel
    include ProcessorPrivate

    def responds?
      callback_data[0] == "valentines_cancel"
    end

    def process!
      valentine = Valentine.find_by(id: callback_data[1])
      valentine.destroy! if valentine.status == "pending"
      groups = Group.participation(user.id)
      [{
        edit_message_text: {
          chat_id: user.id,
          message_id: @message["message"]["message_id"],
          text: I18n.t(
            "valentines.start.text",
            link: bot_url(user.id),
            groups: groups.present? ? I18n.t("valentines.start.text_extra") : ""
          ),
          reply_markup: { inline_keyboard: build_group_buttons(groups) }
        }
      }]
    end

    private

    def build_group_buttons(groups)
      groups&.map { |group| [{ text: group.title, callback_data: "valentines_share:#{group.id}" }] }
    end
  end
end