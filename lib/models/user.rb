class User < ActiveRecord::Base
  has_many :members, dependent: :destroy
  has_many :groups, through: :members
  has_many :sent_valentines, class_name: "Valentine", foreign_key: "sender_id", dependent: :destroy
  has_many :received_valentines, class_name: "Valentine", foreign_key: "recipient_id", dependent: :destroy

  def self.learn(tg_user)
    return if tg_user["is_bot"]
    user = User.find_or_initialize_by(id: tg_user["id"])
    user.username      = tg_user["username"]
    user.first_name    = tg_user["first_name"]
    user.last_name     = tg_user["last_name"]
    user.language_code = tg_user["language_code"]
    user.save!
    user
  end

  def self.su
    User.find_by(id: Initializer.get_su_id)
  end

  def link
    "<a href='tg://user?id=#{id}'>#{full_name}</a>"
  end

  def full_name
    last_name ? "#{first_name} #{last_name}" : first_name
  end

  def admin_groups
    groups.where(members: { status: %w[administrator creator] })
  end

  def received_valentines_count
    received_valentines.count
  end
end