class Merchant::CouponsController < ApplicationController
  def index
    @merchant = current_user.merchant
  end 
end 