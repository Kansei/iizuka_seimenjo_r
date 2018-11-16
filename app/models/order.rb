class Order < ApplicationRecord
  has_many :order_details, dependent: :delete_all
  has_many :menus, through: :order_details

  validates :total_price, numericality: {only_integer: true,
                                         greater_than_or_equal_to: 0}
end

