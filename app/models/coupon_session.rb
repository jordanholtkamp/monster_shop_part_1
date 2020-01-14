class CouponSession
  attr_reader :coupon_contents

  def initialize(coupon_contents)
    @coupon_contents = coupon_contents
  end 

  def add_coupon(coupon)
    @coupon_contents[:info] = coupon
  end
end 