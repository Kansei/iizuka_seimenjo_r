require 'securerandom'

class MenusController < ApplicationController
  before_action :authenticate_user!

  def index
    @menus = Menu.all
  end

  def create
    #ストロングパラメーターを用いる
    @menu = Menu.new(name: params[:menu][:name],
                     price: params[:menu][:price])
    if @menu.save
      redirect_to action: :index
    else
      flash.now[:danger] = "メニューの追加に失敗しました。"
      render action: :new
    end
  end

  def new
    @menu = Menu.new
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def update
    # 変更のあったパラメータだけ更新したい
    @menu = Menu.find(params[:id])
    @menu.name = params[:menu][:name]
    @menu.price = params[:menu][:price]

    if @menu.save
      redirect_to action: :index
    else
      flash.now[:danger] = "メニューの編集に失敗しました。"
      render action: :edit
    end
  end

  def destroy
    @menu = Menu.find(params[:id])

    if @menu.destroy
      redirect_to action: :index
    else
      flash.now[:danger] = "メニューの削除に失敗しました。"
      render action: :edit
    end
  end
end
