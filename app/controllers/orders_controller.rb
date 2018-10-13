class OrdersController < ApplicationController

  def index
  end

  def new
    @menus = Menu.all
  end

  def confirm
    @orders = []
    order_ids = []


    params[:order].each do |order|
      next if order[:quantity].blank?
      order = {menu_id: order[:menu_id],name: nil, price: nil, quantity: order[:quantity].to_i}

      @orders.append(order)
      order_ids.append(order[:menu_id])
    end

    if order_ids.empty?
      redirect_to new_order_path
      return
    end

    order_menus = Menu.where(id: order_ids)

    @total_price = 0
    order_menus.each_with_index do |order_menu, i|
      @orders[i][:name] = order_menu.name
      @orders[i][:price] = order_menu.price

      @total_price += @orders[i][:price] * @orders[i][:quantity]
    end
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
