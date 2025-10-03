module MessageProcessor::Group
  class RandomizeMember
    include ProcessorGroup
    include CommandParameters

    def responds?
      super && I18n.t("randomizer.member.commands_with_anchor").include?(first_parameter)
    end

    def process!
      members = Member
        .where(group: @chat)
        .where.not(status: ["left", "kicked"], user_id: su_id)
        .where("updated_at >= ?", 3.days.ago).to_a
      text = [members.sample.user.link, @message["text"].sub(/^(\S+\s+){2}/, "")].join(" ")
      result = [{ send_message: { chat_id:, text: } }]
      result << { delete_message: { chat_id:, message_id: } } if can_delete_messages?
    end
  end
end