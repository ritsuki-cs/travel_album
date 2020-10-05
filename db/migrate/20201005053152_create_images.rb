class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.string :image
      t.integer :contribute_id
      t.timestamps null: false
    end
  end
end
