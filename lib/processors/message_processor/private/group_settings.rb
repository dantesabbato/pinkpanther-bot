module MessageProcessor::Private
  class GroupSettings
    include ProcessorPrivate

    def responds?
      command == "settings" || I18n.t("groups.settings.commands").include?(message_text)
    end

    def process!
      admin_groups = message_from_su? ? Group.all_enabled : Group.admin_groups(user.id)
      return send_message(I18n.t("groups.text.none")) if admin_groups.blank?
      send_group_selection(admin_groups)
    end

    private

    def send_group_selection(groups)
      inline_keyboard = groups.map { |group| [{ text: group.title, callback_data: "group_settings:#{group.id}" }] }
      send_message(I18n.t("groups.text.many"), { inline_keyboard: inline_keyboard })
    end

    def send_message(text, reply_markup = nil)
      [{ send_message: { chat_id: user.id, text: text, reply_markup: reply_markup } }]
    end
  end
end