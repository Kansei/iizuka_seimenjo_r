class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if params[:done]
      @orders = Order.where(status: 'done').order(updated_at: 'desc')
                    .eager_load(order_details: [:menu]).limit(50)
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
      # 整理券番号

      last = Order.last

      if last.nil?
        last_number = 0
      elsif last.status == 'done'
        last_number = last.number - 1
      else
        last_number = last.number
      end
      number = last_number % 70 + 1

      @order = Order.new(total_price: params[:total_price], status: 'doing', number: number)
      @order.save!

      menus = Menu.all.pluck(:id, :visible)
      menus_hash = menus.map do |menu|
        Hash[*[menu[0], menu[1]]]
      end

      flag = true
      details = params[:order_details]
      details.each do |detail|
        menu_id = detail[:menu_id].to_i
        quantity = detail[:quantity]
        @order.order_details.create!(menu_id: menu_id, quantity: quantity)

        menus_hash.each do |menu_hash|
          next if menu_hash[menu_id].nil?
          flag = false if menu_hash[menu_id]
        end
      end

      @order.update(status: 'done') if flag
    end

    flash.now[:success] = "注文を受け付けました。"
    render :recive

  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "注文の受付に失敗しました。"
    redirect_to new_order_path
  end

  def edit
    @order = Order.find(params[:id])
    @details = @order.order_details.eager_load(:menu)
    menu_ids = @details.map {|detail| detail.menu.id}
    @menus = Menu.where.not(id: menu_ids)
  end

  def update
    if params[:status]
      @order = Order.find(params[:id])

      status = %w(doing waiting done)
      index = status.index(@order.status)
      next_index = (index + 1) % 3

      @order.status = status[next_index]
      @order.save!
    else
      @order = Order.eager_load(:order_details).find(params[:id])
      @details = @order.order_details

      total_price = 0

      ActiveRecord::Base.transaction do
        # 数の修正
        @details.each_with_index do |detail, i|
          i = i.to_s
          quantity = params[:order][:details][i][:quantity].to_i
          price = params[:order][:details][i][:price].to_i
          if quantity == 0
            detail.destroy
          elsif quantity < 0
            flash[:danger] = "数字を入力してください。"
            redirect_to edit_order_path
            return
          else
            detail.quantity = quantity
            detail.save!

            total_price += price * quantity
          end
        end

        # 追加注文
        details = params[:order][:details][:new]
        unless details.nil?
          i = 0
          while !details[i.to_s].nil?
            detail = details[i.to_s]
            id = detail[:menu_id].to_i
            price = detail[:price].to_i
            quantity = detail[:quantity].to_i

            if quantity <= 0
              i += 1
              next
            end

            @order.order_details.create!(menu_id: id, quantity: quantity)
            total_price += price * quantity
            i += 1
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
