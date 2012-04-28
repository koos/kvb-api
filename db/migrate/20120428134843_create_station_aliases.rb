class CreateStationAliases < ActiveRecord::Migration
  def change
    create_table :station_aliases do |t|
      t.belongs_to :station
      t.string :name

      t.timestamps
    end
    add_index :station_aliases, :station_id
  end
end
