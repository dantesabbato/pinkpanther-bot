module CallbackProcessor::Private
  class GroupTriggers
    include ProcessorPrivate

    def responds?
      callback_data[0] == "group_triggers"
    end

    def process!
      group = Group.find(callback_data[1])
      trigger = group.trigger || group.create_trigger!
      trigger.toggle!(callback_data[2].to_sym) if callback_data[2]
      [{
        edit_message_text: {
          chat_id: @message["message"]["chat"]["id"],
          message_id: @message["message"]["message_id"],
          text: I18n.t("groups.triggers.text", group: group.title),
          reply_markup: { inline_keyboard: build_triggers_buttons(group) }
        }
      }]
    end

    private

    def build_triggers_buttons(group)
      trigger = group.trigger || group.create_trigger!
      triggers =  %i[
        multiple_pics_trigger
        telegram_links_trigger
        links_trigger
        arabic_words_trigger
        pics_trigger
        videos_trigger
        repeated_mentions_trigger
      ]
      buttons = [[{
        text: I18n.t("groups.triggers.buttons.banned_words_trigger") + " >>", callback_data: "group_trigger_words:#{group.id}"
      }]]
      buttons += triggers.map do |setting|
        [{
          text: I18n.t(
            "groups.buttons.#{trigger.send(setting) ? "activated" : "deactivated"}",
            name: I18n.t("groups.triggers.buttons.#{setting}")
          ),
          callback_data: "group_triggers:#{group.id}:#{setting}"
        }]
      end
      buttons += [
        [{ text: I18n.t("groups.buttons.back"), callback_data: "group_settings:#{group.id}" }],
        [{ text: I18n.t("groups.buttons.complete"), callback_data: "complete" }]
      ]
    end
  end
end
