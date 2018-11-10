class CreateMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :menus do |t|
      t.string :name
      t.integer :price
      t.boolean :visible
      t.boolean :sale_out

      t.timestamps
    end
  end
end
