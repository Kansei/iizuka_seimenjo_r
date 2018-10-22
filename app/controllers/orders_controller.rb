class OrdersController < ApplicationController

  def index
    orderStruct = Struct.new(:id, :number, :status, :details)
    orderDetailStruct = Struct.new(:name, :quantity)

    orders = Order.where.not(status: 'done')

    @orders = Array.new(orders.size)

    orders.each_with_index do |order, i|
      details = Array.new(order.order_details.size)
      order.order_details.each_with_index do |detail, i|
        details[i] = orderDetailStruct.new(detail.menu.name, detail.quantity)
      end

      @orders[i] = orderStruct.new(order.id, order.number, order.status, details)
    end

    @orders
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
      @order = Order.new(total_price: params[:total_price], status: "doing", number: rand(1000))
      @order.save!

      details = params[:order_details]
      details.each do |detail|
        @order.order_details.create!(menu_id: detail[:menu_id], status: false, quantity: detail[:quantity])
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
    status = %w(doing waiting done)

    @order = Order.find(params[:id])

    2.times do |i|
      if status[i] == @order.status
        @order.status = status[i+1]
        @order.save!
        break
      end
    end

    redirect_to orders_path
  end

  def destroy
    id = params[:id]

    order = Order.find_by(id: id)
    order.destroy

    flash[:success] = "注文を取り消しました。"
    redirect_to new_order_path
  end

end
