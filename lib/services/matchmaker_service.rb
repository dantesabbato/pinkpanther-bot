module MatchmakerService
  class << self
    def call
      Group.where(matchmaking: true).find_each do |group|
        next if Match.exists?(group: group, matched_on: Date.today)

        members = group
          .members
          .where('updated_at >= ?', 3.days.ago.beginning_of_day)
          .where.not(status: %w[left kicked], user_id: User.su.id)

        next if members.size < 5

        ActiveRecord::Base.transaction do
          match = Match.where(group:, matched_on: nil).first
          if match.present?
            match.update!(matched_on: Date.today)
            user1, user2 = match.user1, match.user2
          else
            user1, user2 = select_unique_pair(members, group)
            Match.create!(group:, user1:, user2:, matched_on: Date.today)
          end
          send_message(group, user1, user2)
        end
      rescue => e
        Initializer.get_logger.error("Matchmaker error for group #{group.id}: #{e.message}")
      end
    end

    private

    def select_unique_pair(members, group)
      previous_members = Match.where(group:).pluck(:user1_id, :user2_id).flatten.uniq
      available_members = members.reject { |m| previous_members.include?(m.user_id) }
      available_members = members if available_members.size < 2
      available_members.sample(2).map(&:user)
    end

    def send_message(group, user1, user2)
      params = {
        chat_id: group.telegram_id,
        text: I18n.t(
          'matchmaker.text',
          match: I18n.t('matchmaker.match', user1: user1.link, user2: user2.link),
          comment: (I18n.t 'matchmaker.comments').sample
        ),
        parse_mode: 'html'
      }
      PayloadWorker.perform_async('send_message', params.to_h.deep_stringify_keys)
    end
  end
end
