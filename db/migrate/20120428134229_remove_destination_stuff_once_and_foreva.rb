class RemoveDestinationStuffOnceAndForeva < ActiveRecord::Migration
  def up
    drop_table :unmatched_destinations
    drop_table :destination_lines
    drop_table :destinations
    drop_table :destination_stations
  end

  def down
  end
end
