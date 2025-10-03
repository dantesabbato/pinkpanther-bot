class AddIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :groups, :telegram_id, unique: true
    add_index :users, :id, unique: true
    add_index :members, [:group_id, :user_id], unique: true
    add_index :trigger_words, :group_id
  end
end