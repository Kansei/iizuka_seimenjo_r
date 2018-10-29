class OrderDetailsController < ApplicationController
  before_action :authenticate_user!

  def index
    @details = OrderDetail.all.eager_load(:menu)
    menu_ids = Menu.all.select(:id).pluck(:id)
    total_price = 0

    details_data = []

    menu_ids.each do |menu_id|
      details = @details.where(menu_id: menu_id).select(:quantity)

      detail_total_quantity = 0
      price = details.first.menu.price
      name = details.first.menu.name

      details.each do |detail|
        detail_total_quantity += detail.quantity
      end
      detail_total_price = price * detail_total_quantity
      detail_data = {
          name: name,
          price: price,
          total_quantity: detail_total_quantity,
          total_price: detail_total_price
      }
      details_data.append(detail_data)

      total_price += detail_total_price
    end

    @data = {
        total_price: total_price,
        details: details_data
    }
    render :index
  end
end
