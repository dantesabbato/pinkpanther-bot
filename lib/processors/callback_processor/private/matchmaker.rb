module CallbackProcessor::Private
  class Matchmaker
    include ProcessorPrivate

    def responds?
      callback_data[0] == 'matchmaker'
    end

    def process!
      edit_message(I18n.t('matchmaker.admin.text_add'), nil) if callback_data[2] == "add"
      group = Group.find_by(id: callback_data[1])
      match = Match.find_by(group:, matched_on: nil)
      match = create_match(group) if match.nil? || callback_data[2] == "recreate"
      edit_message(
        I18n.t('matchmaker.admin.text', user1: match.user1.link, user2: match.user2.link),
        reply_markup(group.id)
      )
    end

    private

    def create_match(group)
      members = group
        .members
        .where('updated_at >= ?', 3.days.ago.beginning_of_day)
        .where.not(status: %w[left kicked], user_id: User.su.id)

      previous_members = Match.where(group:).pluck(:user1_id, :user2_id).flatten.uniq
      available_members = members.reject { |m| previous_members.include?(m.user_id) }
      available_members = members if available_members.size < 2
      user1, user2 = available_members.sample(2).map(&:user)
      Match.create!(group:, user1:, user2:)
    end

    def reply_markup(group_id)
      {
        inline_keyboard: [
          [{ text: I18n.t('matchmaker.admin.buttons.recreate'), callback_data: "matchmaker:#{group_id}:recreate" }],
          [{ text: I18n.t('matchmaker.admin.buttons.create_manually'), callback_data: "matchmaker:#{group_id}:manually" }],
          [{ text: I18n.t('support.buttons.complete'), callback_data: "complete" }]
        ]
      }
    end

    def edit_message(text, reply_markup)
      [{ edit_message_text: { chat_id:, message_id: @message["message"]["message_id"], text:, reply_markup: } }]
    end
  end
end