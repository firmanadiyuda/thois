class AddForeignKeyToRaws < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :raws, :sessions
    change_column_null :raws, :session_id, false
  end
end
