class CreatePhotoboothConfigurations < ActiveRecord::Migration[7.2]
  def change
    create_table :photobooth_configurations do |t|
      t.integer :qr_counter, default: 1
      t.integer :camera_counter, default: 1
      t.integer :camera_captured, default: 0
      t.string :camera_ip, default: "http://192.168.8.122:5513/"
      t.integer :mode, default: 0
      t.belongs_to :event

      t.timestamps
    end
  end
end
