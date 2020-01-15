require 'rails_helper'

RSpec.describe 'Cart creation' do
  describe 'When I visit an items show page' do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 25)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
    end

    it "I see a link to add this item to my cart" do
      visit "/items/#{@paper.id}"
      expect(page).to have_button("Add To Cart")
    end

    it "I can add this item to my cart" do
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      expect(page).to have_content("#{@paper.name} was successfully added to your cart")
      expect(current_path).to eq("/items")

      within 'nav' do
        expect(page).to have_content("Cart: 1")
      end

      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      within 'nav' do
        expect(page).to have_content("Cart: 2")
      end
    end
  end

  describe 'when I visit the cart show page' do
    before :each do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
    end

    it 'increments items that are in the cart, and can not increment beyond item inventory amount' do
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@paper.id}" do
        click_button "+"
        expect(page).to have_content("2")
        click_button "+"
        expect(page).to have_content("3")
        click_button "+"
        expect(page).to have_content("3")
      end
    end

    it 'decrements items that are in the cart, and if reaches 0 then item is removed from cart' do
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@paper.id}" do
        click_button "+"
        expect(page).to have_content("2")
        click_button "-"
        expect(page).to have_content("1")
        click_button "-"
      end

      expect(page).to_not have_content(@pencil.name)
    end
  end
end
