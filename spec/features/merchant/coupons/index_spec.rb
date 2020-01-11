require 'rails_helper'

describe 'As a merchant user', type: :feature do 
  before :each do 
    @merchant_company = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 80203)
    @random_merchant = create(:random_merchant)

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
                           value_off: 0.50)

    @coupon_2 = Coupon.new(name: 'Labor Day Sale',
                           code: 'LaborDay2020',
                           value_off: 0.30)

    @random_coupon = Coupon.new(name: 'Black Friday Sale',
                                code: 'BLACKFRIDAY',
                                value_off: 0.25)
    
    @merchant_company.users << @merchant_admin
    @merchant_company.coupons << [@coupon_1, @coupon_2]
    @random_merchant.coupons << @random_coupon
  end 

  describe 'When I am on the merchant dashboard' do 
    it 'shows a link to coupon index' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

      visit '/merchant'

      click_link 'See My Coupons'

      save_and_open_page
      
      expect(current_path).to eq('/merchant/coupons')

      within "#coupon-#{@coupon_1.id}" do 
        expect(page).to have_content(@coupon_1.name)
        expect(page).to have_content(@coupon_1.code)
        expect(page).to have_content("Percentage off: 50.0%")
      end 

      within "#coupon-#{@coupon_2.id}" do 
        expect(page).to have_content(@coupon_2.name)
        expect(page).to have_content(@coupon_2.code)
        expect(page).to have_content("Percentage off: 30.0%")
      end 

      expect(page).not_to have_css("#coupon-#{@random_coupon.id}")
    end 
  end 
end 