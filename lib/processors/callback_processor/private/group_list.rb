module CallbackProcessor::Private
  class GroupList
    include ProcessorPrivate

    def responds?
      callback_data[0] == "group_list"
    end

    def process!
      admin_groups = message_from_su? ? Group.all_enabled : Group.admin_groups(user.id)
      return edit_message(I18n.t("groups.text.none")) if admin_groups.blank?
      send_group_selection(admin_groups)
    end

    private

    def send_group_selection(groups)
      inline_keyboard = groups.map { |group| [{ text: group.title, callback_data: "group_settings:#{group.id}" }] }
      edit_message(I18n.t("groups.text.many"), { inline_keyboard: inline_keyboard })
    end

    def edit_message(text, reply_markup = nil)
      [{
         edit_message_text: {
           chat_id: @message["message"]["chat"]["id"],
           message_id: @message["message"]["message_id"],
           text: text,
           reply_markup: reply_markup
         }
       }]
    end
  end
end