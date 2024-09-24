class AddForeignKeyToSessions < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :sessions, :events
    change_column_null :sessions, :event_id, false
  end
end
