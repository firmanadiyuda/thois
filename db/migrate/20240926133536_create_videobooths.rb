class CreateVideobooths < ActiveRecord::Migration[7.2]
  def change
    create_table :videobooths do |t|
      t.timestamps

      t.integer :counter, default: 0
      t.string :overlay, default: nil
      t.string :overlay_video, default: nil
      t.boolean :use_overlay_video, default: false
      t.string :music, default: nil
      t.boolean :use_music, default: false
      t.integer :quality, default: 0
      t.string :slowmo_one, default: "02.00"
      t.string :slowmo_two, default: "07.00"

      t.belongs_to :event, foreign_key: true
    end
  end
end
