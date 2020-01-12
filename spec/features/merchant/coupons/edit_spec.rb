require 'rails_helper'

describe 'As a merchant user on the coupon index', type: :feature do 
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

  it 'shows a button to edit each coupon that takes me to a form with my data' do 
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

    visit '/merchant/coupons'

    within "#coupon-#{@coupon_1.id}" do 
      click_link 'Edit Coupon'
    end 

    expect(current_path).to eq("/merchant/coupons/#{@coupon_1.id}/edit")

    expect(find_field("Name").value).to eq(@coupon_1.name)
    expect(find_field("Code").value).to eq(@coupon_1.code)
    expect(find_field("Value off").value).to eq('50')
  end 

  it 'can update the attributes for an item' do 
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_admin)

    original_name = @coupon_1.name 
    original_code = @coupon_1.code

    visit '/merchant/coupons'

    within "#coupon-#{@coupon_1.id}" do 
      click_link 'Edit Coupon'
    end 

    new_name = 'thanksgiving sale'
    new_code = 'turkeyboi'
    fill_in :name, with: new_name
    fill_in :code, with: new_code

    click_button 'Update Coupon'

    @coupon_1.reload

    expect(current_path).to eq("/merchant/coupons")

    expect(@coupon_1.name).to eq(new_name)

    visit "/merchant/coupons"

    within "#coupon-#{@coupon_1.id}" do 
      expect(page).to_not have_content(original_name)
      expect(page).to have_content(new_name)
      expect(page).to_not have_content(original_code)
      expect(page).to have_content(new_code)
    end 

    visit "/merchant/coupons/#{@coupon_1.id}/edit"

    fill_in :name, with: 'Labor Day Sale'

    click_button 'Update Coupon'

    expect(page).to have_content('Name has already been taken')
    expect(find_field("Name").value).to eq(new_name)
    expect(find_field("Code").value).to eq(new_code)
    expect(find_field("Value off").value).to eq('50')
  end 
end 