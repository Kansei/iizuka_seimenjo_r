class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :total_price
      t.string :status
      t.integer :number

      t.timestamps
    end
  end
end
