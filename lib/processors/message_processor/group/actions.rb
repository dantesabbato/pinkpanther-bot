module MessageProcessor::Group
  class Actions
    include ProcessorGroup

    def responds?
      super && reply_message.present? && I18n.t('actions').any? { |key, _| message_text_down == key.to_s }
    end

    def process!
      text = I18n.t("actions.#{message_text_down}", user1: user_link(user_from), user2: user_link(user_to))
      result = [{ send_message: { chat_id:, text: } }]
      result << { delete_message: { chat_id:, message_id: } } if can_delete_messages?
    end
  end
end