module MessageProcessor::Private
  class GroupTriggerWords
    include ProcessorPrivate

    def responds?
      private.edit_state&.start_with?("banned_words_trigger:")
    end

    def process!
      group = Group.find_by(id: private.edit_state.split(":")[1])
      return unless group

      add_trigger_words(group)
      private.update!(edit_state: nil)

      trigger = group.trigger || group.create_trigger!
      trigger_words = group.trigger_words.pluck(:word)

      message_text = I18n.t("groups.triggers.text_trigger", trigger: I18n.t("groups.triggers.buttons.banned_words_trigger")) + "\n"
      message_text += trigger_words.any? ? "<code>#{trigger_words.join("\n")}</code>" : I18n.t("groups.triggers.text_none")

      [{
        send_message: {
          chat_id: private.id,
          text: message_text,
          reply_markup: {
            inline_keyboard: [
              [{
                 text: I18n.t(
                   "groups.buttons.#{trigger.banned_words_trigger ? "activated" : "deactivated"}",
                   name: I18n.t("groups.triggers.buttons.banned_words_trigger")
                 ),
                 callback_data: "group_trigger_words:#{group.id}:toggle"
               }],
              [{ text: I18n.t("groups.buttons.edit"), callback_data: "group_trigger_words:#{group.id}:edit" }],
              [{ text: I18n.t("groups.buttons.add"), callback_data: "group_trigger_words:#{group.id}:add" }],
              [{ text: I18n.t("groups.buttons.clear"), callback_data: "group_trigger_words:#{group.id}:clear" }],
              [{ text: I18n.t("groups.buttons.back"), callback_data: "group_triggers:#{group.id}" }]
            ]
          }
        }
      }]
    end

    private

    def add_trigger_words(group)
      existing_words = group.trigger_words.pluck(:word)
      new_words = message_text.split("\n").uniq - existing_words
      new_words.each { |word| group.trigger_words.find_or_create_by(word:) }
    end
  end
end
