class AddGoproCounterToSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :sessions, :gopro_counter, :integer, default: nil
  end
end
