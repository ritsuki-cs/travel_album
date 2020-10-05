class ChangeTypes < ActiveRecord::Migration[5.2]
  def change
    rename_column :types, :type, :name
  end
end
