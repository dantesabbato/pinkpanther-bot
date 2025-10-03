class Private < ActiveRecord::Base
  def self.learn(user)
    private = Private.find_or_initialize_by(id: user.id)
    private.save
  end
end
