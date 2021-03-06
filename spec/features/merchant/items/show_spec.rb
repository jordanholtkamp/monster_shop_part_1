require 'rails_helper'

RSpec.describe 'As a merchant admin/user' do

  before :each do
    @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    @chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
    @shifter = @meg.items.create(name: "Shimano Shifters", description: "It'll always shift!", active?: false, price: 180, image: "https://images-na.ssl-images-amazon.com/images/I/4142WWbN64L._SX466_.jpg", inventory: 2)
    
    @merchant_admin = create(:random_user, role: 2, merchant: @meg)

    @merchant = create(:random_merchant)
    @item_1 = create(:random_item, merchant_id: @merchant.id)
    @item_2 = create(:random_item, merchant_id: @merchant.id)
    @user = create(:random_user)
    @order = create(:random_order, user_id: @user.id)
    @item_1_order = ItemOrder.create!(item: @item_1, order: @order, price: @item_1.price, quantity: 5, status: 1)

    @merchant_user = create(:random_user, role: 3, merchant_id: @merchant.id)
  end

  it "Has a button to delete each item that has never been ordered" do

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_user)

    visit "/merchant/items"

    within "#item-#{@item_1.id}" do
      expect(page).not_to have_link("Delete Item")
    end

    within "#item-#{@item_2.id}" do
      expect(page).to have_link("Delete Item")
    end

  end

  it "can delete the item and show a flash message" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_user)

    visit "/merchant/items"

    within "#item-#{@item_2.id}" do
      click_link "Delete Item"
    end

    @merchant.reload

    expect(current_path).to eq("/merchant/items")
    expect(page).to have_content("You deleted #{@item_2.name}")
    expect(page).to_not have_css("#item-#{@item_2.id}")

  end

  it 'has button to deactive an item next to each item' do

    merchant_user = create(:random_user, merchant_id: @meg.id, role: 3)

    item_1 = create(:random_item, merchant_id: @meg.id)
    item_2 = create(:random_item, merchant_id: @meg.id)
    item_3 = create(:random_item, merchant_id: @meg.id, active?: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_user)

    visit '/merchant/items'

    within "#item-#{item_1.id}" do
      expect(page).to have_button("Deactivate")
    end

    within "#item-#{item_3.id}" do
      expect(page).to_not have_button("Deactivate")
    end

    within "#item-#{item_2.id}" do
      click_button "Deactivate"
    end

    expect(current_path).to eq("/merchant/items")
    expect(page).to have_content("#{item_2.name} is deactivated")
    item_1.reload
    item_2.reload
    item_3.reload
    expect(item_1.active?).to eq(true)
    expect(item_2.active?).to eq(false)
    expect(item_3.active?).to eq(false)

    within "#item-#{item_1.id}" do
      expect(page).to have_content("Active")
    end

    within "#item-#{item_2.id}" do
      expect(page).to have_content("Inactive")
    end
    
    within "#item-#{item_3.id}" do
      expect(page).to have_content("Inactive")
    end
  end 

  it 'can activate a deactivated item' do
    merchant_user = create(:random_user, merchant_id: @meg.id, role: 3)

    item_1 = create(:random_item, merchant_id: @meg.id)
    item_2 = create(:random_item, merchant_id: @meg.id, active?: false)
    item_3 = create(:random_item, merchant_id: @meg.id, active?: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_user)

    visit '/merchant/items'

    within "#item-#{item_1.id}" do
      expect(page).not_to have_button("Activate")
    end

    within "#item-#{item_2.id}" do
      expect(page).to have_button("Activate")
    end

    within "#item-#{item_3.id}" do
      click_button("Activate")
    end

    expect(current_path).to eq("/merchant/items")
    expect(page).to have_content("#{item_3.name} is Activated")
    item_1.reload
    item_2.reload
    item_3.reload
    expect(item_1.active?).to eq(true)
    expect(item_2.active?).to eq(false)
    expect(item_3.active?).to eq(true)
  end
end