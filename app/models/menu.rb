class Menu < ApplicationRecord
  has_many :order_details
  has_many :orders, through: :order_details

  # acvive_strage
  has_one_attached :image

  validates :name, presence: true
  validates :price, presence: true
end
