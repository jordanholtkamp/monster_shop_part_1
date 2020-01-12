require 'rails_helper'

describe 'As a merchant', type: :feature do 
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

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)
  end 

  describe 'On the coupon index page' do 
    it 'shows a button to delete each coupon' do 
      visit '/merchant/coupons'

      id = @coupon_1.id
      name = @coupon_1.name 

      within "#coupon-#{id}" do 
        click_link 'Delete Coupon'
      end 

      expect(current_path).to eq('/merchant/coupons')

      @merchant_company.reload

      expect(@merchant_company.coupons.include?(@coupon_1)).to_not be_truthy 

      expect(page).to_not have_css("coupon-#{id}")
      expect(page).to have_content('You have deleted Half off summer sale')
    end 
  end 
end 