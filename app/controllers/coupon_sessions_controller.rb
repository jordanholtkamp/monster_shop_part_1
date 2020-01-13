class CouponSessionsController < ApplicationController
  def update
    coupon = Coupon.find_by(code: params[:promo_code])
    if coupon
      coupon_session.add_coupon(coupon)
      flash[:success] = "#{coupon.name} has been applied."
    else 
      flash[:error] = 'The coupon promo code you entered does not exist.'
    end
    redirect_to '/cart'
  end 
end 