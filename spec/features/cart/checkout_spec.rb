require 'rails_helper'

RSpec.describe 'Cart show' do
  describe 'When I have added items to my cart' do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"
      @items_in_cart = [@paper,@tire,@pencil]
    end

    it 'Theres a link to checkout' do
      user = create(:random_user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/cart"

      expect(page).to have_link("Checkout")

      click_on "Checkout"

      expect(current_path).to eq("/orders/new")
    end

    describe 'As a visitor' do
      it "tells me I must register or login before checking out" do
        visit '/cart'

        within "#checkout" do
          expect(page).to_not have_link("Checkout")
          expect(page).to have_link('login')
          expect(page).to have_link('register')
          click_link 'register'
        end
        expect(current_path).to eq('/register')

        visit '/cart'

        within "#checkout" do
          click_link 'login'
        end
        expect(current_path).to eq('/login')
      end

      it 'shows a form for me to add a coupon promo code' do 
        @coupon_1 = @mike.coupons.create(name: 'Half off summer sale!',
                                         code: 'summersale',
                                         value_off: 50)

        user = create(:random_user)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit '/orders/new'

        fill_in :promo_code, with: 'not a code'
        click_button 'Apply Promo Code'

        expect(page).to have_content('The coupon promo code you entered does not exist.')

        fill_in :promo_code, with: @coupon_1.code
        click_button 'Apply Promo Code'

        expect(page).to have_content("#{@coupon_1.name} has been applied.")
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

  describe 'When I havent added items to my cart' do
    it 'There is not a link to checkout' do
      visit "/cart"

      expect(page).to_not have_link("Checkout")
    end
  end
end
