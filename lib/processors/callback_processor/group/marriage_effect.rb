module CallbackProcessor::Group
  class MarriageEffect
    include Processor

    def responds?
      Initializer.get_logger.debug "Responding MarriageEffect"
      Initializer.get_logger.debug "callback_data[0]: #{callback_data[0]}"
      Initializer.get_logger.debug "callback_data[1]: #{callback_data[1]}"
      Initializer.get_logger.debug "callback_data[2]: #{callback_data[2]}"
      Initializer.get_logger.debug "callback_data[3]: #{callback_data[3]}"
      Initializer.get_logger.debug "#{user.id}"

      (callback_data[0] == "marriage_effect") && (callback_data[2].to_i == user.id)
    end

    def process!
      Initializer.get_logger.debug "Processing MarriageEffect"
      partner = User.find(callback_data[1])
      marriage = Marriage.effect(partner.id, user.id) if callback_data[3] == "ok"
      [{
        send_message: {
          chat_id: @message["message"]["chat"]["id"],
          text: I18n.t(
            "marriage.effect.#{marriage ? 'callback_accept' : 'callback_reject'}",
            user1: partner.link,
            user2: user.link
          ),
        }
      }]
    end
  end
end