class Menu < ApplicationRecord
  has_many :order_details, dependent: :restrict_with_error
  has_many :orders, through: :order_details,  dependent: :restrict_with_error
end
