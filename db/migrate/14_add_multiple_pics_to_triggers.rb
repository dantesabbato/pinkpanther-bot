class AddMultiplePicsToTriggers < ActiveRecord::Migration[7.2]
  def change
    add_column :triggers, :multiple_pics_trigger, :boolean, default: false
  end
end