module CallbackProcessor::Private
  class Complete
    include ProcessorPrivate

    def responds?
      callback_data[0] == 'complete'
    end

    def process!
      [{
        edit_message_text: {
          chat_id: user.id,
          message_id: @message["message"]["message_id"],
          text: I18n.t('groups.settings.text_complete'),
          reply_markup: nil
        }
      }]
    end
  end
end
