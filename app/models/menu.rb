class Menu < ApplicationRecord
  has_many :order_details
  has_many :orders, throught: :order_details
end
