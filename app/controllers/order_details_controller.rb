class OrderDetailsController < ApplicationController
  before_action :authenticate_user!

  def index
    @menus = Menu.eager_load(:order_details)

    sales_data = []
    total_price = 0

     @menus.each do |menu|
       total_quantity = 0

       menu.order_details.each do |detail|
         total_quantity += detail.quantity
       end

       sub_total_price = total_quantity * menu.price

       sale_data = {
             name: menu.name,
             price: menu.price,
             total_quantity: total_quantity,
             total_price: sub_total_price
       }
       sales_data.append(sale_data)

       total_price += sub_total_price
     end

    @data = {
        total_price: total_price,
        details: sales_data
    }

    render :index
  end
end
