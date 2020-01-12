class Merchant::CouponsController < ApplicationController
  def index
    @merchant = current_user.merchant
  end 

  def new
  end 

  def create
    merchant = current_user.merchant
    coupon = merchant.coupons.create(coupon_params)
    if coupon.save
      redirect_to '/merchant/coupons'
      flash[:success] = 'Your coupon has been created!'
    else
      flash[:error] = coupon.errors.full_messages.to_sentence
      render :new
    end
  end 

  def show
    @coupon = Coupon.find(params[:id])
  end 

  def edit
    @coupon = Coupon.find(params[:id])
  end 

  def update 
    coupon = Coupon.find(params[:id])
    coupon.update(coupon_params)
    if coupon.save
      flash[:success] = "#{coupon.name} has been updated."
      redirect_to '/merchant/coupons'
    else 
      redirect_back(fallback_location: '/merchant/coupons')
      flash[:error] = coupon.errors.full_messages.to_sentence
    end 
  end 

  def destroy
    coupon = Coupon.find(params[:id])
    coupon.destroy
    flash[:notice] = "You have deleted #{coupon.name}"
    redirect_to "/merchant/coupons"
  end 

  private
  
  def coupon_params
    params.permit(:name, :code, :value_off)
  end 
end 