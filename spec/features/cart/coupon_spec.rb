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
                                     value_off: 20)
  
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

    fill_in :promo_code, with: @coupon_1.code
    click_button 'Apply Promo Code'

    expect(page).to have_content("#{@coupon_1.name} has been applied.")
  end 

  describe 'When I enter a promo code on the cart page' do
    it 'discounts the item prices for the merchant items when the code is applied' do
      visit '/cart'

      fill_in :promo_code, with: @coupon_1.code
      click_button 'Apply Promo Code'

      within "#cart-item-#{@item_1.id}" do
        expect(page).to have_content("Discounted Price: $30")
        expect(page).to have_content("Discounted Subtotal: $30")
      end

      within "#cart-item-#{@item_2.id}" do
        expect(page).to have_content("Discounted Price: $10")
        expect(page).to have_content("Discounted Subtotal: $10")
      end

      within "#cart-item-#{@item_3.id}" do
        expect(page).to_not have_content("Discounted Price")
        expect(page).to_not have_content("Discounted Subtotal")
      end
    end
    
    it 'only applies the last coupon that was entered' do 
      visit '/cart'

      fill_in :promo_code, with: @coupon_1.code
      click_button 'Apply Promo Code'

      fill_in :promo_code, with: @coupon_2.code
      click_button 'Apply Promo Code'

      within "#cart-item-#{@item_1.id}" do
        expect(page).to have_content("Discounted Price: $48")
        expect(page).to have_content("Discounted Subtotal: $48")
      end

      within "#cart-item-#{@item_2.id}" do
        expect(page).to have_content("Discounted Price: $16")
        expect(page).to have_content("Discounted Subtotal: $16")
      end

      within "#cart-item-#{@item_3.id}" do
        expect(page).to_not have_content("Discounted Price")
        expect(page).to_not have_content("Discounted Subtotal")
      end

      expect(page).to have_content("Discounted Total: $164")
    end

    it 'does not accept an invalid code' do
      visit '/cart'

      fill_in :promo_code, with: 'clambakesale'
      click_button 'Apply Promo Code'

      expect(page).to have_content('The coupon promo code you entered does not exist.')
    end

    it 'still only applies the last one even if they are from different stores' do 
      new_coupon = @meg.coupons.create(name: 'coup',
                                       code: 'new_coup',
                                       value_off: 20)

      visit '/cart'

      fill_in :promo_code, with: @coupon_1.code
      click_button 'Apply Promo Code'

      fill_in :promo_code, with: new_coupon.code
      click_button 'Apply Promo Code'

      within "#cart-item-#{@item_1.id}" do
        expect(page).to_not have_content("Discounted Price")
        expect(page).to_not have_content("Discounted Subtotal")
      end

      within "#cart-item-#{@item_2.id}" do
        expect(page).to_not have_content("Discounted Price")
        expect(page).to_not have_content("Discounted Subtotal")
      end

      within "#cart-item-#{@item_3.id}" do
        expect(page).to have_content("Discounted Price")
        expect(page).to have_content("Discounted Subtotal")
      end
    end 
  end
end