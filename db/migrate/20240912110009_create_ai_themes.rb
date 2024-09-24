class CreateAiThemes < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_themes do |t|
      t.timestamps

      t.string :name
      t.text :prompt, default: nil
      t.text :negative_prompt, default: nil
      t.text :styles, default: '["Steampunk 2"]'
      t.string :preview
    end
  end
end
