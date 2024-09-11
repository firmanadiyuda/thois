class CreateExports < ActiveRecord::Migration[7.2]
  def change
    create_table :exports do |t|
      t.timestamps

      t.string :filename
      t.string :compress
      t.string :cloud
      t.integer :filetype
      t.boolean :printable, default: false

      t.belongs_to :session
    end
  end
end
