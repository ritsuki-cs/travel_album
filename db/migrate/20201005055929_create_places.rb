class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      t.float :lat
      t.float :lng
      t.string :name
      t.integer :contribute_id
      t.timestamps null: false
    end
  end
end
