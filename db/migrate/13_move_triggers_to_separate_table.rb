class MoveTriggersToSeparateTable < ActiveRecord::Migration[7.2]
  def change
    create_table :triggers do |t|
      t.references :group, null: false, foreign_key: true, index: { unique: true }
      t.boolean :telegram_links_trigger, default: false
      t.boolean :links_trigger, default: false
      t.boolean :pics_trigger, default: false
      t.boolean :videos_trigger, default: false
      t.boolean :banned_words_trigger, default: false
      t.boolean :arabic_words_trigger, default: false
      t.boolean :repeated_mentions_trigger, default: false
      t.timestamps
    end

    remove_column :groups, :telegram_links_trigger, :boolean, default: false
    remove_column :groups, :links_trigger, :boolean, default: false
    remove_column :groups, :pics_trigger, :boolean, default: false
    remove_column :groups, :videos_trigger, :boolean, default: false
    remove_column :groups, :banned_words_trigger, :boolean, default: false
    remove_column :groups, :arabic_words_trigger, :boolean, default: false
  end
end