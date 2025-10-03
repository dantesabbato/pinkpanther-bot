class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, force: true do |t|
      t.string  :username
      t.string  :first_name
      t.string  :last_name
      t.string  :avatar
      t.string  :language_code
      t.date    :birthdate
      t.timestamps
    end
  end
end