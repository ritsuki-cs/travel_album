class CreateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :types do |t|
      t.string :type
      t.timestamps null: false
    end
  end
end
