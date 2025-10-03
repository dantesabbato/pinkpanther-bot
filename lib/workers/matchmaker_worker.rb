require_relative "../../config/initializer"
require_relative "../services/telegram_service"

class MatchmakerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    MatchmakerService.call
  end
end