class CreateGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :groups, force: true do |t|
      t.bigint :telegram_id
      t.string :title
      t.string :username
      t.string :description
      t.string :invite_link
      t.string :language, default: 'ru'
      t.boolean :enabled
      t.boolean :telegram_links_trigger, default: false
      t.boolean :links_trigger, default: false
      t.boolean :pics_trigger, default: false
      t.boolean :videos_trigger, default: false
      t.boolean :banned_words_trigger, default: false
      t.boolean :arabic_words_trigger, default: false
      t.boolean :idling, default: true
      t.boolean :matchmaking, default: false
      t.timestamps
    end
  end
end
