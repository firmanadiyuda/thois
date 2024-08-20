class CreatePhotoboothConfigurations < ActiveRecord::Migration[7.2]
  def change
    create_table :photobooth_configurations do |t|
      t.integer :qr_counter
      t.integer :camera_counter
      t.integer :camera_captured
      t.string :camera_ip
      t.integer :mode
      t.belongs_to :event

      t.timestamps
    end
  end
end
