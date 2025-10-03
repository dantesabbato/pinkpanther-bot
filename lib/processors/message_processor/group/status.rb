module MessageProcessor::Group
  class Status
    include ProcessorGroup
    include CommandParameters

    def responds?
      super && (
        I18n.t("members.status.commands_with_anchor").include?(first_parameter) ||
        I18n.t("members.status.commands").include?(message_text)
      )
    end

    def process!
      spouse = Marriage.find_partner(@user.id)
      valentines_count = @user.received_valentines_count
      [{
        send_message: {
          chat_id: @chat.telegram_id,
          text: I18n.t(
            "members.status.text",
            user: @user.link,
            karma: @member.rating,
            message_count: @member.message_count,
            marriage: I18n.t("members.status.#{spouse ? 'married' : 'not_married'}", spouse: spouse&.link),
            valentines: I18n.t("members.status.valentines", count: valentines_count)
          )
        }
      }]
    end
  end
end