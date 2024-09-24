class AddAiThemeRefToSessions < ActiveRecord::Migration[7.2]
  def change
    add_reference :sessions, :ai_theme, null: true, foreign_key: true
  end
end
