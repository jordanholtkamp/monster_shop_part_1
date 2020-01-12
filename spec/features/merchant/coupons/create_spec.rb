require 'rails_helper'

describe 'As a merchant user' do 
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
                           value_off: 0.50)

    @coupon_2 = Coupon.new(name: 'Labor Day Sale',
                           code: 'LaborDay2020',
                           value_off: 0.30)

    @merchant_company.users << @merchant_admin
    @merchant_company.coupons << [@coupon_1, @coupon_2]
  end 
  describe 'on the coupon index page' do 
    it 'has a link for a new coupon' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

      visit '/merchant/coupons'

      click_link 'Add New Coupon'

      expect(current_path).to eq('/merchant/coupons/new')
    end 
  end 

  describe 'on the form for a new coupon' do 
    it 'has needed fields and can create a new coupon for the merchant' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

      visit '/merchant/coupons/new'

      fill_in :name, with: 'New Year Sale'
      fill_in :code, with: 'NEWYEARNEWME'
      fill_in :value_off, with: 0.25

      click_button 'Create Coupon'

      new_coupon = Coupon.last

      expect(current_path).to eq('/merchant/coupons')
      
      within "#coupon-#{new_coupon.id}" do 
        expect(page).to have_content(new_coupon.name)
        expect(page).to have_content(new_coupon.code)
        expect(page).to have_content("Percentage off: 25.0%")
      end 

      expect(page).to have_content('Your coupon has been created!')
    end 

    it 'cannot create a new coupon if it does not fill in a field or uses non-unique details' do 
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

      visit '/merchant/coupons/new'
      
      fill_in :name, with: 'New Year Sale'
      fill_in :code, with: 'NEWYEARNEWME'

      click_button 'Create Coupon'

      expect(page).to have_content("Value off can't be blank")

      fill_in :name, with: 'Half off summer sale!'
      fill_in :code, with: 'xyz'
      fill_in :value_off, with: 0.50

      click_button 'Create Coupon'

      expect(page).to have_content('Name has already been taken')
    end 
  end 
end 