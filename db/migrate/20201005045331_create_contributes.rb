class CreateContributes < ActiveRecord::Migration[5.2]
  def change
    create_table :contributes do |t|
      t.integer :prefecture_id
      t.integer :type_id
      t.string :comment
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
