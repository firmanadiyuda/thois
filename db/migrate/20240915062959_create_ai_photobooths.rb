class CreateAiPhotobooths < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_photobooths do |t|
      t.timestamps

      t.boolean :print, default: 0
      t.integer :paper, default: 0
      t.boolean :thermal, default: 0
      t.string :overlay, default: nil
      t.string :ai_api, default: nil
      t.integer :selected_themes, default: [], array: true

      t.belongs_to :event
    end
  end
end
