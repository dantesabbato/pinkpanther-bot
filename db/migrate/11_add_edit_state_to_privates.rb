class AddEditStateToPrivates < ActiveRecord::Migration[7.2]
  def change
    add_column :privates, :edit_state, :string, default: nil
  end
end