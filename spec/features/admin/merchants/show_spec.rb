require 'rails_helper'

RSpec.describe 'As an Admin' do
  it 'can not allow me to go to merchant page or cart' do
    admin = create(:random_user, role:1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

    expect(admin.role).to eq("admin")

    visit '/merchant'
    expect(page).to have_content("The page you were looking for doesn't exist (404)")

    visit '/cart'
    expect(page).to have_content("The page you were looking for doesn't exist (404)")
  end

  it "can see a merchant's dashboard" do
    admin = create(:random_user, role: 1)
    merchant = create(:random_merchant)
    user = create(:random_user, role: 0)
    user_2 = create(:random_user, role: 0)
    item = create(:random_item, merchant_id: merchant.id)
    item_2 = create(:random_item, merchant_id: merchant.id)
    order = create(:random_order, user_id: user.id, current_status: 0)
    order_2 = create(:random_order, user_id: user_2.id, current_status: 1)

    item_order = ItemOrder.create!(item: item, order: order, price: item.price, quantity: 2, status: 1)
    item_order_2 = ItemOrder.create!(item: item_2, order: order_2, price: item_2.price, quantity: 1, status: 1)

    visit '/'

    click_link "Login"
    expect(current_path).to eq('/login')

    fill_in :email, with: admin.email
    fill_in :password, with: admin.password

    click_button "Login"

    visit "/admin/merchants"
    click_on("#{merchant.name}")
    expect(current_path).to eql("/admin/merchants/#{merchant.id}")

    expect(page).to have_content("#{merchant.name}")
    expect(page).to have_content("#{merchant.address}")
    expect(page).to have_content("#{merchant.city}")
    expect(page).to have_content("#{merchant.state}")
    expect(page).to have_content("#{merchant.zip}")

    within "#order-pending-#{order.id}" do
      expect(page).to have_content("#{order.id}")
      expect(page).to have_content("Date Created: #{order.created_at}")
      expect(page).to have_content("Total Quantity: #{order.items.count}")
      expect(page).to have_content("Total: #{order.grandtotal}")
    end

    expect(page).to_not have_content("ID: #{order_2.id}")
  end

  it "can see button to disable each merchant if the merchant is not disabled" do
    admin = create(:random_user, role: 1)
    merchant_enabled = create(:random_merchant)
    merchant_enabled2 = create(:random_merchant)
    merchant_disabled = create(:random_merchant, status: 1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

    visit '/admin/merchants'

    within "#merchant-#{merchant_disabled.id}" do
      expect(page).to_not have_button('Disable Merchant')
    end

    within "#merchant-#{merchant_enabled.id}" do
      click_button('Disable Merchant')
    end

    expect(current_path).to eq('/admin/merchants')

    within "#merchant-#{merchant_enabled.id}" do
      expect(page).to_not have_button('Disable Merchant')
    end

    within "#merchant-#{merchant_enabled2.id}" do
      expect(page).to have_button('Disable Merchant')
    end

    merchant = Merchant.find(merchant_enabled.id)

    expect(merchant.disabled?).to be_truthy
    expect(merchant_enabled2.enabled?).to be_truthy

    flash = "You have disabled #{merchant_enabled.name}"

    expect(page).to have_content(flash)
  end

  it "Can enable a disabled merchant " do
    admin = create(:random_user, role: 1)
    merchant_enabled = create(:random_merchant)
    merchant_disabled = create(:random_merchant, status: 1)
    merchant_disabled2 = create(:random_merchant, status:1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

    visit '/admin/merchants'

    within "#merchant-#{merchant_disabled.id}" do
      click_button "Enable Merchant"
    end

    merchant_disabled.reload

    within "#merchant-#{merchant_disabled.id}" do
      expect(page).to_not have_button "Enable Merchant"
      expect(page).to have_button "Disable Merchant"
    end

    expect(merchant_disabled.enabled?).to be_truthy
    expect(page).to have_content("You have enabled #{merchant_disabled.name}")
  end

  it "disables a merchant's items if the merchant is disabled" do
    admin = create(:random_user, role: 1)
    merchant = create(:random_merchant)
    merchant_2 = create(:random_merchant)
    item = create(:random_item, merchant_id: merchant.id)
    item_2 = create(:random_item, merchant_id: merchant_2.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

    visit "/admin/merchants"

    within "#merchant-#{merchant.id}" do
      click_button "Disable Merchant"
    end

    visit "/items"

    expect(page).not_to have_content(item.name)
    expect(page).not_to have_css("img[src*='#{item.image}']")
    expect(page).to have_content(item_2.name)
    expect(page).to have_css("img[src*='#{item_2.image}']")

    item.reload
    item_2.reload

    expect(item.active?).to eq(false)
    expect(item_2.active?).to eq(true)
  end

  it "enables a merchant's items if merchant is enabled" do
    admin = create(:random_user, role: 1)
    merchant = create(:random_merchant, status: 1)
    merchant_2 = create(:random_merchant)
    item = create(:random_item, merchant_id: merchant.id, active?: false)
    item_2 = create(:random_item, merchant_id: merchant_2.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

    visit "/admin/merchants"

    within "#merchant-#{merchant.id}" do
      click_button "Enable Merchant"
    end

    item.reload
    item_2.reload

    visit "/items"

    expect(page).to have_content(item_2.name)
    expect(page).to have_content(item.name)

    expect(item.active?).to eq(true)
    expect(item_2.active?).to eq(true)
  end
end
