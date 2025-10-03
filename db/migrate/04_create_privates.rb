class CreatePrivates < ActiveRecord::Migration[7.2]
  def change
    create_table :privates, force: true do |t|
      t.boolean :stopped, default: false
      t.string :language, default: 'ru'
      t.timestamps
    end
  end
end
