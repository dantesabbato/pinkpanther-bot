class CreateMatches < ActiveRecord::Migration[7.2]
  def change
    create_table :matches, force: true do |t|
      t.references :group,      null: false, foreign_key: true
      t.references :user1,      null: false, foreign_key: { to_table: :users }
      t.references :user2,      null: false, foreign_key: { to_table: :users }
      t.date       :matched_on, null: false
    end
  end
end