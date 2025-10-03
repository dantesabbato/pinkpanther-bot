module ProcessorGroup
  include Processor

  REQUIRED_PERMISSIONS = %w[can_change_info can_delete_messages can_restrict_members can_invite_users can_pin_messages].freeze

  def responds?
    @chat&.enabled
  end

  private

  # def admin_permissions_sufficient?
  #   @logger.debug "Checking admin permissions"
  #   member = @bot.api.get_chat_member(chat_id: @message.chat.id, user_id: @bot.api.get_me.id)
  #   unless member.status == "administrator"
  #     all_rights = REQUIRED_PERMISSIONS.map { |perm| I18n.t "group.error.admin_missing.rights.#{perm}" }.join("\n")
  #     send_message("#{I18n.t 'group.error.admin_missing.give_status'}\n#{all_rights}")
  #     return false
  #   end
  #   missing_permissions = REQUIRED_PERMISSIONS.reject { |perm| member.public_send(perm) == true }
  #   if missing_permissions.any?
  #     missing_rights = missing_permissions.map { |perm| I18n.t "group.error.admin_missing.rights.#{perm}" }.join("\n")
  #     send_message("#{I18n.t 'group.error.admin_missing.give_permissions'}\n#{missing_rights}")
  #     return false
  #   end
  #   true
  # end

  def just_anchor?
    words&.one? && I18n.t("bot.anchor").include?(words&.first)
  end

  def reply_user
    @reply_user ||= User.find_by(id: @message["reply_to_message"]["from"]["id"])
  end

  def reply_message
    @reply_message ||= @message["reply_to_message"]
  end

  def member
    @member
  end

  def message_from_admin?
    @member.status == "administrator" || @member.status == "creator" || message_from_su?
  end

  def message_from_creator?
    @member.status == "creator"
  end

  def bot_id
    @bot_id ||= YAML.load(ERB.new(IO.read("config/secrets.yml")).result)["bot"]["token"].split(":")[0].to_i
  end

  def admins
    @admins ||= @chat.learn_admins(@bot)
  end

  def can_delete_messages?(user_id: bot_id)
    @bot.getChatMember(chat_id: @chat.telegram_id, user_id: user_id).can_delete_messages
  end

  def can_restrict_members?(user_id: bot_id)
    @bot.getChatMember(chat_id: @chat.telegram_id, user_id: user_id).can_restrict_members
  end
end