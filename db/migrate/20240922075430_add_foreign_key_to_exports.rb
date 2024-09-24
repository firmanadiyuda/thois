class AddForeignKeyToExports < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :exports, :sessions
    change_column_null :exports, :session_id, false
  end
end
