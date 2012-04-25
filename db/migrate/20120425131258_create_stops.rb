class CreateStops < ActiveRecord::Migration
  def up
    create_table :stops do |c|
      c.float :lat
      c.float :long
      c.string :type
      c.integer :station_id
    end

    add_column :stations, :kvb_id, :integer

  end

  def down
    remove_column :stations, :kvb_id

    drop_table :stops
  end
end
