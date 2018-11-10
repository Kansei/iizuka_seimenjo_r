require 'securerandom'

class MenusController < ApplicationController
  before_action :authenticate_user!

  def index
    @menus = Menu.all
  end

  def create
    #ストロングパラメーターを用いる
    @menu = Menu.new(name: params[:menu][:name],
                     price: params[:menu][:price],
                     visible: params[:menu][:visible],
                     sale_out: false
    )
    if @menu.save
      redirect_to action: :index
      return
    else
      flash.now[:danger] = "メニューの追加に失敗しました。"
      render action: :new
      return
    end
  end

  def new
    @menu = Menu.new
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def update
    if params[:sale_out]
      @menu = Menu.find(params[:id])
      @menu.sale_out = !@menu.sale_out
      unless @menu.save
        flash.now[:danger] = "メニューの編集に失敗しました。"
      end
      redirect_to action: :index
      return
    else
      @menu = Menu.find(params[:id])
      @menu.name = params[:menu][:name]
      @menu.visible = params[:menu][:visible]

      if @menu.save
        flash[:success] = "メニューを編集しました。"
        redirect_to action: :index
      else
        flash.now[:danger] = "メニューの編集に失敗しました。"
        render action: :edit
        return
      end
    end
  end

  def destroy
    @menu = Menu.find(params[:id])

    if @menu.destroy
      redirect_to action: :index
      return
    else
      flash.now[:danger] = "メニューの削除に失敗しました。"
      render action: :edit
      return
    end
  end
end
