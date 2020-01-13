require 'rails_helper'

describe 'As a user', type: :feature do
  before :each do
    @mike = create(:random_merchant)
    @meg = create(:random_merchant)

    @item_1 = create(:random_item, merchant_id: @mike.id, price: 60)
    @item_2 = create(:random_item, merchant_id: @mike.id, price: 20)
    @item_3 = create(:random_item, merchant_id: @meg.id, price: 100)

    @coupon_1 = @mike.coupons.create(name: 'Half off summer sale!',
                                     code: 'summersale',
                                     value_off: 50)

    @coupon_2 = @mike.coupons.create(name: 'New member',
                                     code: 'Welcome15',
                                     value_off: 15)
  
    user = create(:random_user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/items/#{@item_1.id}"
      click_on "Add To Cart"
      visit "/items/#{@item_2.id}"
      click_on "Add To Cart"
      visit "/items/#{@item_3.id}"
      click_on "Add To Cart"
      @items_in_cart = [@item_1,@item_2,@item_3]
  end

  it 'shows a form for me to add a coupon promo code on the cart page' do 
    visit '/cart'

    # fill_in :promo_code, with: 'not a code'
    # click_button 'Apply Promo Code'

    # expect(page).to have_content('The coupon promo code you entered does not exist.')

    fill_in :promo_code, with: @coupon_1.code
    click_button 'Apply Promo Code'

    expect(page).to have_content("#{@coupon_1.name} has been applied.")
  end 

  describe 'When I enter a promo code on the cart page' do
    it 'discounts the item prices for the merchant items when the code is applied' do
      visit '/cart'

      # expect(page).to have_content("Discounted total: 180")
      # expect(page).to have_content("Savings: 0")

      fill_in :promo_code, with: @coupon_1.code
      click_button 'Apply Promo Code'

      visit '/cart'

      # expect(page).to have_content("Discounted total: 140")
      expect(page).to have_content("Savings: 40")

    end
    
    it 'only applies the last coupon that was entered' do 
      @coupon_1 = @mike.coupons.create(name: 'Half off summer sale!',
                                       code: 'summersale',
                                       value_off: 50)

      @coupon_2 = @mike.coupons.create(name: 'Labor Day Sale',
                                       code: 'LABORDAY25',
                                       value_off: 25)

      user = create(:random_user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      
      #TODO: make test to see which coupon is stored in the session when putting in two coupon codes. It will always apply the last one and can only use one per order even if they have items from different stores
    end
  end
end