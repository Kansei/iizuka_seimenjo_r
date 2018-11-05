class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if params[:done]
      @orders = Order.where(status: 'done').order(updated_at: 'desc')
      .eager_load(order_details: [:menu])
    else
      @orders = Order.where.not(status: 'done').eager_load(order_details: [:menu])
    end
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
      next if quantity.blank? || quantity < 1
      order = {menu_id: order[:menu_id], name: nil, price: nil, quantity: quantity}

      @orders.append(order)
      order_ids.append(order[:menu_id])
    end

    if order_ids.empty?
      flash[:danger] = "数字を入力してください。"
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
      last = Order.last
      id = last.nil? ? 0 : last.id
      number = id % 30 + 1

      @order = Order.new(total_price: params[:total_price], status: 'doing', number: number)
      @order.save!

      details = params[:order_details]
      details.each do |detail|
        @order.order_details.create!(menu_id: detail[:menu_id], quantity: detail[:quantity])
      end
    end

    render :recive and return

  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = "注文の受付に失敗しました。"
    render :recive
  end

  def edit
    @order = Order.find(params[:id])
    @details = @order.order_details.eager_load(:menu)
  end

  def update
    if params[:status]
      @order = Order.find(params[:id])

      status = %w(doing waiting done)
      index = status.index(@order.status)
      next_index = (index+1) % 3

      @order.status = status[next_index]
      @order.save!
    else
      @order = Order.eager_load(:order_details).find(params[:id])
      @details = @order.order_details

      total_price = 0

      ActiveRecord::Base.transaction do
        @details.each_with_index do |detail, i|
          quantity = params[:order][:details][i][:quantity].to_i
          if quantity == 0
            detail.destroy
          elsif quantity < 0
            flash[:danger] = "数字を入力してください。"
            redirect_to edit_order_path
            return
          else
            detail.quantity = quantity
            detail.save!

            total_price += detail.menu.price * quantity
          end
        end
        price_differential = @order.total_price - total_price
        @order.total_price = total_price
        @order.save!

        if price_differential > 0
          message = "差額の#{price_differential}円をご返金してください。"
        elsif price_differential < 0
          message = "差額の#{-price_differential}円を頂いてください。"
        else
          message = "差額は発生しません。"
        end
        flash[:success] = "注文を修正しました。#{message}"
      end
    end

    redirect_to orders_path

  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "注文の修正に失敗しました"
    redirect_to orders_path
  end

  def destroy
    id = params[:id]

    order = Order.find_by(id: id)
    order.destroy

    flash[:success] = "注文を取り消しました。"
    if request.fullpath == "/orders"
      redirect_to new_order_path
      return
    else
      redirect_to orders_path
      return
    end
  end
end
