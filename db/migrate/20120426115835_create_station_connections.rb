class CreateStationConnections < ActiveRecord::Migration
  def change
    create_table :station_connections do |t|
      t.integer :station_a_id
      t.integer :station_b_id
      t.float :distance

      t.timestamps
    end
  end
end
