module MessageProcessor::Group
  class MatchMembers
    include ProcessorGroup
    include CommandParameters

    def responds?
      super && message_from_admin? && I18n.t('matchmaker.commands_with_anchor').include?(first_parameter)
    end

    def process!
      members = @chat
        .members
        .where('updated_at >= ?', 3.days.ago.beginning_of_day)
        .where.not(status: %w[left kicked], user_id: su_id)
      return match_refuse if members.size < 5

      today_match = Match.find_by(group: @chat, matched_on: Date.today)
      return match_repeat(today_match.user1.link, today_match.user2.link) if today_match.present?

      match = Match.where(group: @chat, matched_on: nil).first
      if match.present?
        match.update!(matched_on: Date.today)
        return match_now(match.user1.link, match.user2.link)
      end

      previous_members = Match.where(group:).pluck(:user1_id, :user2_id).flatten.uniq
      available_members = members.reject { |m| previous_members.include?(m.user_id) }
      available_members = members if available_members.size < 2
      user1, user2 = available_members.sample(2).map(&:user)
      today_match = Match.create!(group: @chat, user1:, user2:, matched_on: Date.today)
      match_now(today_match.user1.link, today_match.user2.link)
    rescue => e
      Initializer.get_logger.error("Matchmaker error: #{e.message}")
    end

    private

    def send_message(text)
      result = [{ send_message: { chat_id:, text: } }]
      result << { delete_message: { chat_id:, message_id: } } if can_delete_messages?
      result
    end

    def match_now(user1, user2)
      send_message(
        I18n.t(
          'matchmaker.text',
          match: I18n.t('matchmaker.match', user1:, user2:),
          comment: (I18n.t 'matchmaker.comments').sample
        )
      )
    end

    def match_repeat(user1, user2)
      send_message(
        I18n.t(
          'matchmaker.text_repeat',
          match: I18n.t('matchmaker.match', user1:, user2:),
          repeat: I18n.t('matchmaker.repeat', duration: remaining_time)
        )
      )
    end

    def match_refuse
      send_message(I18n.t('matchmaker.text_refuse'))
    end

    def remaining_time(locale = :ru)
      now = Time.now
      next_match_time = Time.new(now.year, now.month, now.day, 11, 0, 0)
      remaining_seconds = (next_match_time - now).to_i

      hours = remaining_seconds / 3600
      minutes = (remaining_seconds % 3600) / 60

      hours_text = InflectorService.inflect(locale, 'hours', hours)
      minutes_text = InflectorService.inflect(locale, 'minutes', minutes)

      "#{hours} #{hours_text} #{minutes} #{minutes_text}"
    end
  end
end