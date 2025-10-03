class Member < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  scope :admins, ->(group_id) { where(group_id:, status: ["creator", "administrator"]) }

  def self.learn(group, user, text: nil)
    return if group.nil? || user.nil?
    member = Member.find_or_initialize_by(group:, user:)
    if text
      member.word_count ||= 0
      member.message_count ||= 0
      member.word_count += text.to_s.split.size
      member.message_count += 1 if text.to_s.size.positive?
    end
    member.status ||= "member"
    member.save
    MemberStatusWorker.perform_async(group.id, user.id)
    member
  end
end