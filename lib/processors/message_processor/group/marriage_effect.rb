module MessageProcessor::Group
  class MarriageEffect
    include ProcessorGroup

    def responds?
      super && (
        I18n.t("marriage.effect.commands").include?(message_text) && @message["reply_to_message"] ||
          I18n.t("marriage.effect.commands").include?(command_to_user)
      )
    end

    def process!
      reply_user ||= User.find_by(username: words[0][1..])
      return if reply_user.nil?
      return [{
        send_message: { chat_id:, text: I18n.t("marriage.effect.text_not_in_group", user2: reply_user.link) }
      }] unless valid_group_member?(reply_user)
      partner = Marriage.find_marriage(reply_user.id)
      spouse = Marriage.find_partner(@user.id)
      return [{
        send_message: { chat_id:, text:  I18n.t("marriage.effect.text_busy_2", user2: reply_user.link) }
      }] if partner
      return [{
        send_message: { chat_id:, text:  I18n.t("marriage.effect.text_busy_1", partner: spouse.link) }
      }] if spouse
      [{
        send_message: {
          chat_id:,
          text: I18n.t("marriage.effect.text", user1: @user.link, user2: reply_user.link),
          reply_markup: {
            inline_keyboard: [[
              { text: I18n.t("marriage.effect.button_accept"), callback_data: "marriage_effect:#{@user.id}:#{reply_user.id}:ok" },
              { text: I18n.t("marriage.effect.button_reject"), callback_data: "marriage_effect:#{@user.id}:#{reply_user.id}" }
            ]]
          }
        }
      }]
    end

    private

    def valid_group_member?(user)
      member = Member.find_by(group: @chat, user:)
      member && !%w[left kicked].include?(member.status)
    end
  end
end