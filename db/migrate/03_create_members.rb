class CreateMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :members, force: true do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer    :word_count
      t.integer    :message_count
      t.string     :status
      t.references :invited_by, foreign_key: { to_table: :users }
      t.references :kicked_by, foreign_key: { to_table: :users }
      t.boolean    :is_superior, default: false
      t.string     :nicknames, array: true, default: []
      t.integer    :rating, default: 0
      t.timestamps
    end
  end
end
