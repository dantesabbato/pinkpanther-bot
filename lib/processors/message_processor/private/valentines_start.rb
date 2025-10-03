module MessageProcessor::Private
  class ValentinesStart
    include ProcessorPrivate
    include CommandParameters

    def responds?
      command == "start" && words[1] == "valentines"
    end

    def process!
      groups = Group.participation(user.id)
      Initializer.get_logger.debug "GROUPS: #{groups.inspect}"
      [{
        send_message: {
          chat_id: @message["chat"]["id"],
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