class CreatePrefectures < ActiveRecord::Migration[5.2]
  def change
    create_table :prefectures do |t|
      t.string :prefecture
      t.timestamps null: false
    end
  end
end
