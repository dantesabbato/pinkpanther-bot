module MessageProcessor::Group
  class RatingIncrease
    include ProcessorGroup

    def responds?
      super &&
        @message["reply_to_message"] && (
          I18n.t("members.rating.up.commands").include?(words[0]) ||
            message_text == "+" ||
            message_text == "+++" ||
            message_text == "👍"
        )
    end

    def process!
      member = Member.find_by(user_id: reply_user.id)
      Initializer.get_logger.debug "member: #{member.inspect}"
      return if member.nil?
      member.increment!(:rating)
      [{ send_message: { chat_id:, text: I18n.t("members.rating.up.text", user: reply_user.link, count: member.rating) } }]
    end
  end
end