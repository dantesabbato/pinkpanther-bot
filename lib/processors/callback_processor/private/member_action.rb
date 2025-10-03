module CallbackProcessor::Private
  class MemberAction
    include ProcessorPrivate

    def responds?
      callback_data[0] == "member_action"
    end

    def process!
      member = Member.find_by(id: callback_data[1])
      return error_response if member.nil?
      chat = member.group
      action = callback_data[2]
      case action
      when "ban" then ban_member(chat.telegram_id, member.user_id)
      when "unmute" then unmute_member(chat.telegram_id, member)
      end
      notify_admins(chat, action, member)
      clean_notifications(member.id)
      [{}]
    end

    private

    def error_response
      [{
        edit_message_text: {
          chat_id: @message["message"]["chat"]["id"],
          message_id: @message["message"]["message_id"],
          text: I18n.t("triggers.notification.text_error"),
          reply_markup: nil
        }
      }]
    end

    def ban_member(chat_id, user_id)
      @bot.banChatMember(chat_id:, user_id:)
    end

    def unmute_member(chat_id, member)
      member.update!(is_superior: true)
      @bot.restrictChatMember(
        chat_id:,
        user_id: member.user_id,
        permissions: Telegram::Bot::Types::ChatPermissions.new(
          can_send_messages: true,
          can_send_media_messages: true,
          can_send_polls: true,
          can_send_other_messages: true,
          can_add_web_page_previews: true,
          can_change_info: true,
          can_invite_users: true,
          can_pin_messages: true
        )
      )
    end

    def notify_admins(group, action, member)
      current_admin = Member.find_by(user:, group:)
      notifications = Notification.where(type: "trigger", value: member.id)
      notifications.each do |notification|
        @bot.edit_message_text(
          chat_id: notification.member.user_id,
          message_id: notification.message_id,
          text: I18n.t(
            "triggers.notification.text_done.#{action == 'ban' ? 'banned' : 'unmuted'}",
            user: member.user.link,
            admin: current_admin.user.link
          ),
          reply_markup: nil,
          parse_mode: "HTML"
        )
      end
      media = Notification.where(type: "trigger_media", value: member.id)
      media.each do |item|
        @bot.delete_message(chat_id: item.member.user_id, message_id: item.message_id)
      end
    end

    def clean_notifications(value)
      Notification.where(type: "trigger", value:).destroy_all
      Notification.where(type: "trigger_media", value:).destroy_all
    end
  end
end
