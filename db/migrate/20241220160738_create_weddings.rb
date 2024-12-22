class CreateWeddings < ActiveRecord::Migration[7.2]
  def change
    create_table :weddings do |t|
      t.timestamps

      t.boolean :thermal, default: 1
      t.string :overlay, default: nil
      t.boolean :use_overlay, default: 0
      t.string :cam_dir, default: "DCIM/100CANON"

      t.belongs_to :event, foreign_key: true
    end
  end
end
