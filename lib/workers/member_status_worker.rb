require_relative "../../config/initializer"
require_relative "../services/telegram_service"

class MemberStatusWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  sidekiq_options queue: "default", retry: 5

  sidekiq_throttle(
    concurrency: { limit: 25 },
    threshold: { limit: 9_000, period: 1.hour }
  )

  def perform(group_id, user_id)
    Initializer.get_logger.debug "Started UpdateMemberStatusWorker"
    group = Group.find_by(id: group_id)
    user = User.find_by(id: user_id)
    return if group.nil? || user.nil?

    begin
      status = TelegramService.bot_api.get_chat_member(chat_id: group.telegram_id, user_id: user.id).status
      member = Member.find_by(group:, user:)
      return if member.nil?

      member.status = status
      member.is_superior = true if %w[creator administrator].include?(status)
      member.save
      Initializer.get_logger.debug "Member: #{member.inspect}"
    rescue Telegram::Bot::Exceptions::ResponseError => e
      if e.message.include?("Forbidden: bot was kicked from the supergroup chat")
        group.update!(enabled: false)
      else
        raise
      end
    end
  end
end