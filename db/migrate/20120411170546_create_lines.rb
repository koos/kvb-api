class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.string :number
      t.string :kind

      t.timestamps
    end
  end
end
