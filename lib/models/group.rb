class Group < ActiveRecord::Base
  has_one :trigger, dependent: :destroy
  has_many :trigger_words, dependent: :destroy
  has_many :members
  has_many :users, through: :members

  scope :all_enabled,   -> { where(enabled: true) }
  scope :participation, ->(user_id) { joins(:members).where(enabled: true, members: { user_id: user_id }) }
  scope :admin_groups,  ->(user_id) do
    joins(:members).where(enabled: true, members: { user_id: user_id, status: ["creator", "administrator"] }).distinct
  end

  STATUSES = { true => "🟢", false => "🔴", nil => "⚪️" }.freeze

  def self.learn(tg_group)
    conditions = { telegram_id: tg_group["id"] }
    conditions[:username] = tg_group["username"] if tg_group["username"].present?
    conditions[:title] = tg_group["title"] if tg_group["title"].present?
    group = Group.find_by(conditions) ||
            Group.create!(telegram_id: tg_group["id"], title: tg_group["title"], username: tg_group["username"])
    group.update!(
      title: tg_group["title"],
      username: tg_group["username"],
      description: tg_group["description"].presence,
      invite_link: tg_group["invite_link"].presence
    )
    group
  end

  def enable!
    update!(enabled: true)
  end

  def disable!
    update!(enabled: false)
  end

  def status_icon
    STATUSES[enabled]
  end

  def link
    username ? "<a href='tg://resolve?domain=#{username}'>#{title}</a>" : title
  end

  def learn_admins(bot)
    admins = bot.getChatAdministrators(chat_id: telegram_id)
    current_admin_ids = admins.map { |admin| admin.user.id }
    admins.each do |admin|
      user = User.learn(admin.user.to_h.deep_stringify_keys)
      Member.learn(self, user)&.update(status: admin.status)
    end
    members.where(status: %w[administrator creator])
           .where.not(user_id: current_admin_ids).update_all(status: "member")
    Member.admins(id)
  end

  def member_count
    uri = URI("https://api.telegram.org/bot#{Initializer.get_token}/getChatMemberCount")
    result = JSON.parse(Net::HTTP.post_form(uri, { chat_id: telegram_id }).body)
    result["result"] if result["ok"]
  end
end