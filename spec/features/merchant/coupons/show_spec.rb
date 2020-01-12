require 'rails_helper'

describe 'As a merchant user', type: :feature do 
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

  describe 'on the coupon index page' do 
    it 'each coupon name is a link to the show page' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

      visit '/merchant/coupons'

      within "#coupon-#{@coupon_1.id}" do 
        click_link "#{@coupon_1.name}"
      end 

      expect(current_path).to eq("/merchant/coupons/#{@coupon_1.id}")
      expect(page).to have_content("Coupon for #{@merchant_company.name}")
      expect(page).to have_content(@coupon_1.name)
      expect(page).to have_content(@coupon_1.code)
      expect(page).to have_content(@coupon_1.value_off)
    end 
  end 
end 