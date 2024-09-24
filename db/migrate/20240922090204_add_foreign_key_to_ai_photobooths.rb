class AddForeignKeyToAiPhotobooths < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :ai_photobooths, :events
    change_column_null :ai_photobooths, :event_id, false
  end
end
