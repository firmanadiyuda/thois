class CreateRaws < ActiveRecord::Migration[7.2]
  def change
    create_table :raws do |t|
      t.timestamps

      t.string :filename
      t.string :compress
      t.string :cloud
      t.integer :filetype
      t.boolean :selected

      t.belongs_to :session
    end
  end
end
