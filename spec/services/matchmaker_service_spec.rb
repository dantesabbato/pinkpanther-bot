require 'spec_helper'
require_relative '../../lib/services/matchmaker_service'
require_relative '../../lib/models/group'
require_relative '../../lib/models/member'
require_relative '../../lib/models/match'

RSpec.describe MatchmakerService do
  describe '.call' do
    let(:group) { create(:group, matchmaking: true) }
    let(:user1) { create(:member, group: group).user }
    let(:user2) { create(:member, group: group).user }
    before do
      create_list(:member, 5, group: group, updated_at: Time.now - 1.day, status: "member")
      # Мокаем `order('RANDOM()').limit(2)` - возвращаем фиксированных пользователей
      allow_any_instance_of(ActiveRecord::Relation).to receive(:order).and_return([user1, user2])
      # Очищаем предыдущие матч-данные
      allow(Match).to receive(:where).and_return(Match)
      allow(Match).to receive(:delete_all)
    end
    it "создаёт новую пару и отправляет сообщение" do
      expect(PayloadWorker).to receive(:perform_async).with(
        "send_message",
        hash_including(
          "chat_id" => group.telegram_id,
          "text" => include(user1.link, user2.link), # Проверяем, что в тексте есть ссылки на пользователей
          "parse_mode" => "html"
        )
      )
      MatchmakerService.call
      match = Match.find_by(group: group)
      expect(match).not_to be_nil
      expect(match.user1).to eq(user1)
      expect(match.user2).to eq(user2)
      expect(match.matched_on).to eq(Date.today)
    end
  end
end