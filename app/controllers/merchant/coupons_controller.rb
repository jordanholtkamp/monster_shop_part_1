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

  private
  
  def coupon_params
    params.permit(:name, :code, :value_off)
  end 
end 