require 'rails_helper'

describe Coupon, type: :model do
  describe 'validations' do 
    it { should validate_presence_of :name }
    it { should validate_presence_of :code }
    it { should validate_presence_of :value_off }
    it { should validate_uniqueness_of :name }
    it { should validate_uniqueness_of :code }
    it { should validate_numericality_of :value_off }
    end 

  describe 'relationships' do 
    it { should have_many :orders }
    it { should belong_to :merchant }
  end 

  describe 'model methods' do 
    before :each do 
      @merchant_company = create(:random_merchant)
  
      @merchant_admin = User.create(name: "Jordan",
                                    address: "394 High St",
                                    city: "Denver",
                                    state: "CO",
                                    zip_code: "80602",
                                    email: "hotones@hotmail.com",
                                    password: "password",
                                    password_confirmation: "password",
                                    role: 2)
  
      @coupon_1 = Coupon.new(name: 'Half off summer sale!',
                             code: 'summersale',
                             value_off: 50)
  
      @coupon_2 = Coupon.new(name: 'Labor Day Sale',
                             code: 'LaborDay2020',
                             value_off: 30)
  
      @merchant_company.users << @merchant_admin
      @merchant_company.coupons << [@coupon_1, @coupon_2]
    end 

    it 'no_orders?' do
      user = create(:random_user)
      order = create(:random_order, user_id: user.id, coupon_id: @coupon_1.id)

      expect(@coupon_1.no_orders?).to_not be_truthy
      expect(@coupon_2.no_orders?).to be_truthy
    end 
  end 
end