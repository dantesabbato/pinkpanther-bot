module MessageProcessor::Group
  class RatingDecrease
    include ProcessorGroup

    def responds?
      super && I18n.t("members.rating.down.commands").include?(message_text) && @message["reply_to_message"]
    end

    def process!
      member = Member.find_by(user_id: reply_user.id)
      return if member.nil? || member.user_id == su_id
      member.decrement!(:rating)
      [{ send_message: { chat_id:, text: I18n.t("members.rating.down.text", user: reply_user.link, count: member.rating) } }]
    end
  end
end