require 'rails_helper'

RSpec.describe "as a registered user" do
  it 'shows the coupon used on the order show page' do
    mike = create(:random_merchant)
    user = create(:random_user)
    item_1 = create(:random_item, merchant_id: mike.id)
    coupon = mike.coupons.create(name: 'Summer Sale',
                                  code: 'summer20',
                                  value_off: 20)
  
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    
    visit "/items/#{item_1.id}"
    click_on "Add To Cart"
    
    visit '/cart'

    fill_in :promo_code, with: coupon.code
    click_button 'Apply Promo Code'

    click_link 'Checkout'

    name = "Bert"
    address = "123 Sesame St."
    city = "NYC"
    state = "New York"
    zip = 10001

    fill_in :name, with: name
    fill_in :address, with: address
    fill_in :city, with: city
    fill_in :state, with: state
    fill_in :zip, with: zip

    click_button 'Create Order'

    new_order = Order.last
      
    visit "/profile/orders/#{new_order.id}"
    
    within "#coupon" do
      expect(page).to have_content("Coupon used for this order: #{coupon.name}")
    end
  end

  before :each do
    @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
    meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @tire = meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
    @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
    @user = create(:random_user)

    @order = @user.orders.create(name: "Jordan", address: "123 Hi Road", city: "Cleveland", state: "OH", zip: "44333")
    @tire_order = ItemOrder.create!(item: @tire, order: @order, price: @tire.price, quantity: 5)
    @paper_order = ItemOrder.create!(item: @paper, order: @order, price: @paper.price, quantity: 3)
    @pencil_order = ItemOrder.create!(item: @pencil, order: @order, price: @pencil.price, quantity: 9)

    visit '/'

    click_link "Login"
    expect(current_path).to eq('/login')

    fill_in :email, with: @user.email
    fill_in :password, with: @user.password
    click_button "Login"
  end
  
  describe "when I visit my order index page" do
    it "the order ID links to the order show page" do
      visit "/profile/orders"

      click_link "#{@order.id}"

      expect(current_path).to eq("/profile/orders/#{@order.id}")
    end

    it "it has all order information on show page" do
      visit "/profile/orders/#{@order.id}"

      expect(page).to have_content(@order.id)
      expect(page).to have_content(@order.created_at)
      expect(page).to have_content("This order was placed at: #{@order.created_at}")
      expect(page).to have_content("This order was updated at: #{@order.updated_at}")
      expect(page).to have_content(@order.current_status.upcase)

      expect(page).to have_content(@tire.name)
      expect(page).to have_css("img[src='#{@tire.image}']")
      expect(page).to have_content(@tire_order.quantity)
      expect(page).to have_content(@tire.price)
      expect(page).to have_content(@tire_order.subtotal)

      expect(page).to have_content(@paper.name)
      expect(page).to have_css("img[src='#{@paper.image}']")
      expect(page).to have_content(@paper_order.quantity)
      expect(page).to have_content(@paper.price)
      expect(page).to have_content(@paper_order.subtotal)

      expect(page).to have_content(@pencil.name)
      expect(page).to have_css("img[src='#{@pencil.image}']")
      expect(page).to have_content(@pencil_order.quantity)
      expect(page).to have_content(@pencil.price)
      expect(page).to have_content(@pencil_order.subtotal)

      expect(page).to have_content(@order.grandtotal)
      expect(page).to have_content(@order.items.count)
    end

    describe "As a merchant" do
      it "will see that the order status changes from pending to packaged when items fulfilled" do
        mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)

        visit '/profile'

        click_on "Log Out"

        merchant_user = create(:random_user, role: 2)
        mike.users << merchant_user

        visit '/'

        click_link "Login"
        expect(current_path).to eq('/login')

        fill_in :email, with: merchant_user.email
        fill_in :password, with: merchant_user.password
        click_button "Login"

        merchant_order = @user.orders.create(name: "Ali Wong", address: "123 Always Be My Maybe", city: "San Francisco", state: "CA", zip: "87654")

        ItemOrder.create!(item: @tire, order: merchant_order, price: @tire.price, quantity: 2, status:1)
        ItemOrder.create!(item: @paper, order: merchant_order, price: @paper.price, quantity: 3, status:1)
        ItemOrder.create!(item: @pencil, order: merchant_order, price: @pencil.price, quantity: 1)

        expect(merchant_order.current_status).to eql("pending")

        merchant_order.fulfill

        expect(merchant_order.current_status).to eql("packaged")
      end
    end
  end
end
