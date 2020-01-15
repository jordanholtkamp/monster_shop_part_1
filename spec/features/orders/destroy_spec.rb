require 'rails_helper'

RSpec.describe "As a default user" do

  before :each do
    @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    @paper = @meg.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)


    @user = create(:random_user)

    @order = @user.orders.create(name: "Jordan", address: "123 Hi Road", city: "Cleveland", state: "OH", zip: "44333")

    @tire_order = ItemOrder.create!(item: @tire, order: @order, price: @tire.price, quantity: 5, status: 1)

    @paper_order = ItemOrder.create!(item: @paper, order: @order, price: @paper.price, quantity: 3, status: 1)
  end

  describe 'When I am on the order show page' do
    it "has a button to cancel that order if it is not shipped" do
      visit "/login"
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"

      visit "/profile/orders/#{@order.id}"

      expect(page).to have_content("PENDING")

      within "#cancel" do
        expect(page).to have_button("Cancel Order")
      end

      @order.fulfill
      visit "/profile/orders/#{@order.id}"
      within "#cancel" do
        expect(page).to have_button("Cancel Order")
      end

      @order.ship
      visit "/profile/orders/#{@order.id}"
      within "#cancel" do
        expect(page).not_to have_button("Cancel Order")
      end
    end

    it "the order is given a status of cancelled and I am redirected to my profile page" do
      visit "/login"

      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"

      visit "/profile/orders/#{@order.id}"

      click_button "Cancel Order"

      order = Order.find(@order.id)
      expect(order.current_status).to eq("cancelled")
      expect(current_path).to eq("/profile")
    end

    describe "When I cancel the order" do
      it "gives a status to item_order of unfulfilled" do
        order_2 = @user.orders.create(name: "Jordan", address: "123 Hi Road", city: "Cleveland", state: "OH", zip: "44333")
        ItemOrder.create!(item: @tire, order: order_2, price: @tire.price, quantity: 5, status: 1)

        visit "/login"
        fill_in :email, with: @user.email
        fill_in :password, with: @user.password
        click_button "Login"

        @order.item_orders.each do |item_order|
          expect(item_order.fulfilled?).to be_truthy
        end

        @order.cancel

        @order.item_orders.each do |item_order|
          expect(item_order.unfulfilled?).to be_truthy
        end

        order_2.item_orders.each do |item_order|
          expect(item_order.fulfilled?).to be_truthy
        end
      end

      it "adds item_order quantity back to item inventory" do
        visit "/login"
        fill_in :email, with: @user.email
        fill_in :password, with: @user.password
        click_button "Login"

        visit "/profile/orders/#{@order.id}"
        click_button "Cancel Order"

        expect(@meg.items.first.inventory).to eq(17)
        expect(@meg.items.last.inventory).to eq(6)
      end

      it "sends flash message that order has been cancelled" do
        visit "/login"
        fill_in :email, with: @user.email
        fill_in :password, with: @user.password
        click_button "Login"

        visit "/profile/orders/#{@order.id}"
        click_button "Cancel Order"

        expect(page).to have_content("Your order has been cancelled.")
      end
    end
  end
end
