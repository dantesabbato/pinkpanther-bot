class Marriage < ActiveRecord::Base
  belongs_to :first,  class_name: 'User'
  belongs_to :second, class_name: 'User'

  scope :active,  ->          { where(divorce_date: nil).order(marriage_date: :asc) }
  scope :by_user, ->(user_id) { where("first_id = :id OR second_id = :id", id: user_id) }

  def self.find_marriage(user_id)
    active.by_user(user_id).first
  end

  def self.find_partner(user_id)
    active.by_user(user_id).first&.partner(user_id)
  end

  def self.effect(user1_id, user2_id)
    create!(first_id: user1_id, second_id: user2_id, marriage_date: Time.now)
  end

  def divorce
    update!(divorce_date: Time.now)
    self
  end

  def partner(user_id)
    first_id == user_id ? second : first
  end

  def duration(locale: :ru)
    parts = time_parts(marriage_date).map do |unit, value|
      "#{value} #{InflectorService.inflect(locale, unit, value)}"
    end
    parts.first(2).join(" ")
  end

  private

  def time_parts(from_time)
    difference = (Time.now - from_time.to_time).to_i
    {
      years:  difference / (365 * 24 * 3600),
      months: (difference % (365 * 24 * 3600)) / (30 * 24 * 3600),
      days:   (difference % (30 * 24 * 3600)) / (24 * 3600),
      hours:  (difference % (24 * 3600)) / 3600,
      minutes: (difference % 3600) / 60,
      seconds: difference % 60
    }.reject { |_unit, value| value.zero? }
  end
end
