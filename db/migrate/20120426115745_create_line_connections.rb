class CreateLineConnections < ActiveRecord::Migration
  def change
    create_table :line_connections do |t|
      t.integer :station_connection_id
      t.integer :line_id
      t.integer :order

      t.timestamps
    end
  end
end
