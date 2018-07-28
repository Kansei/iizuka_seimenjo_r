class AddMenuidToMenu < ActiveRecord::Migration[5.2]
  def change
    add_column :menus, :menu_id, :integer
  end
end
