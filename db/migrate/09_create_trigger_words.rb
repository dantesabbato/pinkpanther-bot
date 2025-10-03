class CreateTriggerWords < ActiveRecord::Migration[7.2]
  def change
    create_table :trigger_words do |t|
      t.references :group, foreign_key: true, null: false
      t.string :word, null: false
      t.timestamps
    end
    add_index :trigger_words, [:group_id, :word], unique: true
  end
end