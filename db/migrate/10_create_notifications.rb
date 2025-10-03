class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :member, foreign_key: true, null: false
      t.string :type, null: false
      t.bigint :message_id, null: false
      t.string :value
      t.timestamps
    end
  end
end