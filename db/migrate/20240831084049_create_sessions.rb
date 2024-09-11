class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions do |t|
      t.timestamps

      t.integer :status
      t.text :error

      t.belongs_to :event
    end
  end
end
