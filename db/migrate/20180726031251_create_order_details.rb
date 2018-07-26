class CreateOrderDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :order_details do |t|
      t.references :order, foreign_key: true
      t.references :menu, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
