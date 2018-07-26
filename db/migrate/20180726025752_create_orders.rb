class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :total_price
      t.string :status
      t.time :time
      t.references :customer, foreign_key: true

      t.timestamps
    end
  end
end
