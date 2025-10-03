class RemoveInvitedAndKickedFromMembers < ActiveRecord::Migration[7.2]
  def change
    remove_reference :members, :invited_by, foreign_key: { to_table: :users }
    remove_reference :members, :kicked_by, foreign_key: { to_table: :users }
  end
end