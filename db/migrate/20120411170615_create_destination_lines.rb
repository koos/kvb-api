class CreateDestinationLines < ActiveRecord::Migration
  def change
    create_table :destination_lines do |t|
      t.integer :line_id
      t.integer :destination_id

      t.timestamps
    end
  end
end
