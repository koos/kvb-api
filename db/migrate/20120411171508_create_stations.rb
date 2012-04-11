class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :name
      t.string :platform
      t.text :description
      t.integer :features
      t.float :lat
      t.float :lng
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :station_identifier
      t.timestamps
    end
  end
end
