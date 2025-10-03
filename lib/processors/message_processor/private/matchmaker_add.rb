module MessageProcessor::Private
  class MatchmakerAdd
    include ProcessorPrivate

    def responds?
      private.edit_state&.start_with?("matchmaker:")
    end

    def process!
      group = Group.find_by(id: private.edit_state.split(":")[1])
      return send_message(I18n.t('errors.not_found.group')) unless group

      users = message_text.split(" ")
      user1, user2 = users.map { |user| user.start_with("@") ? User.find_by(username: user[1..-1])&.id : user }
      return send_message(I18n.t('')) if user1.nil? || user2.nil?
      return send_message(I18n.t('errors.not_found.members'))  unless validate_users(user1, user2)

      match = Match.find_by(group:, matched_on: nil)&.update!(user1:, user2:)
      return send_message(I18n.t('errors.not_found.match')) unless match

      send_message(I18n.t('matchmaker.admin.text_already'), inline_keyboard)
    rescue => e
      send_message("MatchmakerAdd error: #{e.message}")
    end

    private

    def inline_keyboard
      [
        [{ text: I18n.t('matchmaker.admin.buttons.recreate'), callback_data: "matchmaker:#{group.id}:recreate" }],
        [{ text: I18n.t('matchmaker.admin.buttons.create_manually'), callback_data: "matchmaker:#{group.id}:manually" }],
        [{ text: I18n.t('support.buttons.complete'), callback_data: "complete" }]
      ]
    end

    def validate_users(group, *user_ids)
      Member.find_by(group:, user_id: user_ids).count == user_ids.size
    end

    def send_message(text, inline_keyboard = nil)
      private.update!(edit_state: nil)
      [{ send_message: { chat_id:, text:, reply_markup: { inline_keyboard: } } }]
    end
  end
end