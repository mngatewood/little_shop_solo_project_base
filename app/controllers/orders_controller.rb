class OrdersController < ApplicationController
  def index
    if request.fullpath == '/orders'
      if current_admin?
        @orders = Order.all
      else
        @orders = current_user.orders.where.not(status: :disabled)
      end
    elsif params[:user_id] && request.fullpath == "/users/#{params[:user_id]}/orders"
      @user = User.find(params[:user_id])
      if current_admin?
        @orders = Order.all
      # elsif @user == current_user
        # @orders = @user.orders.where.not(status: :disabled)
      # else
        # render file: 'errors/not_found', status: 404
      end
    elsif params[:merchant_id] && request.fullpath == "/merchants/#{params[:merchant_id]}/orders"
      render file: 'errors/not_found', status: 404 unless current_admin?
      @merchant = User.find(params[:merchant_id])
      @orders = @merchant.merchant_orders
    end
  end

  def create
    address = Address.find(order_params[:address])
    items = Item.where(id: @cart.contents.keys)
    order = Order.create!(
      user: current_user, 
      status: :pending,
      street: address.street,
      city: address.city,
      state: address.state,
      zip: address.zip)
    items.each do |item|
      order.order_items.create!(
        item: item, 
        price: item.price, 
        quantity: @cart.count_of(item.id), 
        fulfilled: false)
    end
    session[:cart] = nil
    @cart = Cart.new({})
    redirect_to profile_orders_path
  end

  def update
    user = User.find(params[:user_id])
    render file: 'errors/not_found', status: 404 unless current_admin? || current_user == user
    order = Order.find(params[:id])
    render file: 'errors/not_found', status: 404 unless order
    
    if params[:status]
      if params[:status] == 'cancel'
        order.order_items.each do |oi|
          if oi.fulfilled
            oi.fulfilled = false
            oi.save
            oi.item.inventory += oi.quantity
            oi.item.save
          end
        end
        order.update(status: :cancelled)
      end
    elsif order_params[:address]
      address = Address.find(order_params[:address])
      order.update(
        street: address.street,
        city: address.city,
        state: address.state,
        zip: address.zip)
      flash[:notice] = "Shipping address updated."
      end
    redirect_to current_admin? ? user_orders_path(user) : profile_orders_path
  end

  def show
    @order = Order.find(params[:id])
    render file: 'errors/not_found', status: 404 unless current_user || current_user.user? && current_user == @order.user || current_user.merchant? && current_user.merchant_for_order(@order) || current_admin?
    @user = @order.user
    @no_items_fulfilled = @order.order_items.none? {|oi| oi.fulfilled }
  end

  def new
    @order = Order.new
    @user = User.find(params[:user_id])
    @addresses = @user.addresses.where(active: true).order(default: :desc)
  end

  def edit
    @order = Order.find(params[:id])
    @user = User.find(@order.user_id)
    @addresses = @user.addresses
  end

  private

  def order_params
    params.require(:order).permit(:address)
  end
end
