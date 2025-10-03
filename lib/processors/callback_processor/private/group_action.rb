module CallbackProcessor::Private
  class GroupAction
    include ProcessorPrivate

    def responds?
      Initializer.get_logger.debug "#{@message["data"]}"
      Initializer.get_logger.debug "CALLBACK DATA: #{callback_data.inspect}"
      callback_data[0] == "group_action" && message_from_su?
    end

    def process!
      group = Group.find(callback_data[1].to_i)
      return unless group
      callback_data[2] == "ok" ? enable_group(group) : disable_group(group)
    end

    private

    def enable_group(group)
      group.enable!
      send_response(
        chat_message: I18n.t("bot.enabled.text"),
        private_message: I18n.t("groups.new.text_#{group.enabled ? 'enabled' : 'error'}", group_title: group.title),
        group: group
      )
    end

    def disable_group(group)
      group.disable!
      send_response(
        chat_message: nil,
        private_message: I18n.t("groups.new.text_#{group.enabled ? 'error' : 'abandon'}", group_title: group.title),
        group: group,
        leave_chat: true
      )
    end

    def send_response(chat_message:, private_message:, group:, leave_chat: false)
      responses = []
      responses << { send_message: { chat_id: group.telegram_id, text: chat_message } } if chat_message
      responses << { leave_chat: { chat_id: group.telegram_id } } if leave_chat
      responses << {
        edit_message_text: {
          chat_id: @message["message"]["chat"]["id"],
          message_id: @message["message"]["message_id"],
          text: private_message,
          reply_markup: nil
        }
      }
      responses
    end
  end
end