class OrdersController < ApplicationController

  def index
  end

  def new
    @menus = Menu.all
  end

  def confirm
    orders = params[:order]

    @orders = []
    order_ids = []

    orders.each do |order|
      quantity = order[:quantity].to_i
      next if quantity.blank? ||quantity < 1
      order = {menu_id: order[:menu_id], name: nil, price: nil, quantity: quantity}

      @orders.append(order)
      order_ids.append(order[:menu_id])
    end

    if order_ids.empty?
      flash[:danger] = "ちゃんと数を入力して。次はないよ。"
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
    ActiveRecord::Base.transaction do
      order = Order.new(total_price: params[:total_price], status: "doing", number: rand(1000))
      order.save!

      @order_number = order.number

      details = params[:order_details]
      details.each do |detail|
        order.order_details.create!(menu_id: detail[:menu_id], status: false, quantity: detail[:quantity])
      end
    end

    render :recive and return

  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = "注文の受付に失敗しました。"
    render :recive
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
