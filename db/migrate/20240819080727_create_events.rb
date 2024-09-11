class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.timestamps

      t.string :name
      t.text :description
      t.integer :booth_type, default: 0
    end
  end
end
