class Merchant::CouponsController < ApplicationController
  def index
    @merchant = current_user.merchant
  end 

  def new
  end 

  def create
    merchant = current_user.merchant
    merchant.coupons.create(coupon_params)
    redirect_to '/merchant/coupons'
    flash[:success] = 'Your coupon has been created!'
  end 

  private
  
  def coupon_params
    params.permit(:name, :code, :value_off)
  end 
end 