class ChangeMatchedOnInMatches < ActiveRecord::Migration[7.2]
  def change
    change_column_null :matches, :matched_on, true
  end
end