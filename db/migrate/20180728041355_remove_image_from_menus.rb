class RemoveImageFromMenus < ActiveRecord::Migration[5.2]
  def change
    remove_column :menus, :image, :string
  end
end
