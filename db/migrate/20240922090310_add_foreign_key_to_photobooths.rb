class AddForeignKeyToPhotobooths < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :photobooths, :events
    change_column_null :photobooths, :event_id, false
  end
end
