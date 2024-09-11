class CreatePhotobooths < ActiveRecord::Migration[7.2]
  def change
    create_table :photobooths do |t|
      t.timestamps

      t.boolean :print, default: 0
      t.integer :paper, default: 0
      t.boolean :thermal, default: 0
      t.string :overlay, default: nil
      t.jsonb :overlay_layout, default: nil
      t.string :overlay_horizontal, default: nil
      t.boolean :use_overlay_horizontal, default: 0

      t.belongs_to :event
    end
  end
end
