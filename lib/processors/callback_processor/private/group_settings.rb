module CallbackProcessor::Private
  class GroupSettings
    include ProcessorPrivate

    def responds?
      callback_data[0] == "group_settings"
    end

    def process!
      group = Group.find(callback_data[1])
      trigger = group.trigger || group.create_trigger!
      trigger.toggle!(callback_data[2].to_sym) if callback_data[2]
      [{
        edit_message_text: {
          chat_id: @message["message"]["chat"]["id"],
          message_id: @message["message"]["message_id"],
          text: I18n.t("groups.settings.text", group: group.title),
          reply_markup: { inline_keyboard: build_settings_buttons(group) }
        }
      }]
    end

    private

    def build_settings_buttons(group)
      settings =  %i[matchmaking idling]
      buttons = [[{
        text: I18n.t("groups.settings.buttons.triggers") + " >>",
        callback_data: "group_triggers:#{group.id}"
      }]]
      buttons += settings.map do |setting|
        [{
           text: I18n.t(
             "groups.buttons.#{group.send(setting) ? "activated" : "deactivated"}",
             name: I18n.t("groups.settings.buttons.#{setting}")
           ),
           callback_data: "group_settings:#{group.id}:#{setting}"
         }]
      end
      buttons << [{ text: I18n.t("groups.buttons.back"), callback_data: "group_list" }]
      buttons << [{ text: I18n.t("groups.buttons.complete"), callback_data: "complete" }]
    end
  end
end