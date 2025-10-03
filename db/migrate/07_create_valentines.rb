class CreateValentines < ActiveRecord::Migration[7.2]
  def change
    create_table :valentines, force: true do |t|
      t.references :sender,     null: false, foreign_key: { to_table: :users }
      t.references :recipient,  null: false, foreign_key: { to_table: :users }
      t.text       :text
      t.string     :photo
      t.string     :video
      t.string     :voice
      t.string     :animation
      t.string     :sticker
      t.string     :video_note
      t.string     :audio
      t.text       :caption
      t.string     :status,  default: "pending"
      t.timestamps
    end
  end
end