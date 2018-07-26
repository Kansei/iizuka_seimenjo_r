class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_details
  has_many :menus, throught: :order_details
end

