class OrderDetail < ApplicationRecord
  belongs_to :order
  belongs_to :menu

  validates :quantity, numericality: {only_integer: true, greater_than: 0}
end
