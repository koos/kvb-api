class CreateDestinationStations < ActiveRecord::Migration
  def change
    create_table :destination_stations do |t|
      t.integer :destination_id
      t.integer :station_id

      t.timestamps
    end
  end
end
