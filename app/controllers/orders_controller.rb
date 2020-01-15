class OrdersController <ApplicationController

  def new
  end

  def index
    @user = current_user
  end

  def show
    @order = Order.find(params[:id])
  end

  def create
    order = current_user.orders.create(order_params)
    give_optional_coupon(order)
    if order.save && order.coupon_id.nil?
      create_item_orders_with_no_coupon(cart, order)
    elsif order.save
      create_item_orders_with_coupon(cart, order)
    else
      flash[:notice] = "Please complete address form to create an order."
      render :new
    end
  end

  def update
    order = Order.find(params[:id])
    order.cancel
    redirect_to "/profile"
    flash[:notice] = "Your order has been cancelled."
  end


  private

  def order_params
    params.permit(:name, :address, :city, :state, :zip, :current_status)
  end

  def create_item_orders_with_no_coupon(cart, order)
    cart.items.each do |item,quantity|
      order.item_orders.create({
        item: item,
        quantity: quantity,
        price: item.price
        })
    end
    session.delete(:cart)
    flash[:success] = 'You have placed your order!'
    redirect_to '/profile/orders'
  end

  def create_item_orders_with_coupon(cart, order)
    cart.items.each do |item,quantity|
      if item.discountable?(coupon_session)
        order.item_orders.create({
          item: item,
          quantity: quantity,
          price: item.discounted_price(coupon_session)
        })
      else
        order.item_orders.create({
          item: item,
          quantity: quantity,
          price: item.price
        })
      end
    end
    session.delete(:cart)
    session.delete(:coupon)
    flash[:success] = 'You have placed your order!'
    redirect_to '/profile/orders'
  end

  def give_optional_coupon(order)
    if !coupon_session.nil?
      order.coupon_id = coupon_session.id
    end
  end
end
