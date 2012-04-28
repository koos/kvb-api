class AddStationConnectionTravelTime < ActiveRecord::Migration
  def up
    add_column :station_connections, :travel_time, :integer
  end

  def down
    remove_column :station_connections, :travel_time
  end
end
