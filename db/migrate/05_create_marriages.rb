class CreateMarriages < ActiveRecord::Migration[7.2]
  def change
    create_table :marriages, force: true do |t|
      t.references :first, null: false, foreign_key: { to_table: :users }
      t.references :second, null: false, foreign_key: { to_table: :users }
      t.datetime   :marriage_date, null: false
      t.datetime   :divorce_date
    end
  end
end