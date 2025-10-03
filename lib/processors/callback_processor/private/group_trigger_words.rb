module CallbackProcessor::Private
  class GroupTriggerWords
    include ProcessorPrivate

    def responds?
      callback_data[0] == "group_trigger_words"
    end

    def process!
      group = Group.find(callback_data[1])
      trigger = group.trigger || group.create_trigger!
      action = callback_data[2]

      return add_words(group) if action == "add"

      case action
      when "toggle" then trigger.toggle!(:banned_words_trigger)
      when "clear"  then group.trigger_words.destroy_all
      when "cancel" then private.update!(edit_state: nil)
      end

      list_words(group)
    end

    private

    def list_words(group)
      trigger = group.trigger || group.create_trigger!
      trigger_words = group.trigger_words.pluck(:word)
      text = I18n.t("groups.triggers.text_trigger", trigger: I18n.t("groups.triggers.buttons.banned_words_trigger")) + "\n"
      text += trigger_words.any? ? "<code>#{trigger_words.join("\n")}</code>" : I18n.t("groups.triggers.text_none")
      [{
         edit_message_text: {
           chat_id: @message["message"]["chat"]["id"],
           message_id: @message["message"]["message_id"],
           text: text,
           reply_markup: {
             inline_keyboard: [
               [{
                  text: I18n.t(
                    "groups.buttons.#{trigger.banned_words_trigger ? "activated" : "deactivated"}",
                    name: I18n.t("groups.triggers.buttons.banned_words_trigger")
                  ),
                  callback_data: "group_trigger_words:#{group.id}:toggle"
                }],
               [{ text: I18n.t("groups.buttons.add"), callback_data: "group_trigger_words:#{group.id}:add" }],
               [{ text: I18n.t("groups.buttons.clear"), callback_data: "group_trigger_words:#{group.id}:clear" }],
               [{ text: I18n.t("groups.buttons.back"), callback_data: "group_triggers:#{group.id}" }]
             ]
           }
         }
       }]
    end

    def add_words(group)
      private.update!(edit_state: "banned_words_trigger:#{group.id}")
      [{
        edit_message_text: {
          chat_id: @message["message"]["chat"]["id"],
          message_id: @message["message"]["message_id"],
          text:  I18n.t("groups.triggers.text_add"),
          reply_markup: {
            inline_keyboard: [[{
              text: I18n.t("groups.buttons.cancel"), callback_data: "group_trigger_words:#{group.id}:cancel"
            }]]
          }
        }
      }]
    end
  end
end
