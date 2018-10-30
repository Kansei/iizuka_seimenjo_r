class Menu < ApplicationRecord
  has_many :order_detail
  has_many :orders, through: :order_details
end
