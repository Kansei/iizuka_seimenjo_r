class Menu < ApplicationRecord
  has_many :order_details
  has_many :orders, throught: :order_details

  # acvive_strage
  has_one_attached :image
end
