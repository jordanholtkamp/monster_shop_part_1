require 'rails_helper'

RSpec.describe "As an admin" do
  it "can login and be redirected to admin dashboard" do
    user = create(:random_user, role: 1)

    visit '/'

    click_link "Login"
    expect(current_path).to eq('/login')

    fill_in :email, with: user.email
    fill_in :password, with: user.password

    click_button "Login"

    expect(current_path).to eq("/admin")
    expect(page).to have_content("Welcome, #{user.name}, you are logged in!")
  end

  it "can see all orders, their id, date created and status" do
    admin = create(:random_user, role: 1)
    user = create(:random_user, role: 0)
    user_2 = create(:random_user, role: 0)
    order = create(:random_order, user_id: user.id, current_status: 0)
    order_2 = create(:random_order, user_id: user.id, current_status: 1)
    order_3 = create(:random_order, user_id: user_2.id, current_status: 2)
    order_4 = create(:random_order, user_id: user_2.id, current_status: 3)
    merchant = create(:random_merchant)
    item_1 = create(:random_item, merchant_id: merchant.id)
    item_2 = create(:random_item, merchant_id: merchant.id)
    item_order = ItemOrder.create!(item: item_1, order: order, price: item_1.price, quantity: 1)
    item_order_2 = ItemOrder.create!(item: item_2, order: order_2, price: item_2.price, quantity: 2, status: 1)
    item_order_3 = ItemOrder.create!(item: item_1, order: order_3, price: item_1.price, quantity: 3, status: 1)
    item_order_4 = ItemOrder.create!(item: item_2, order: order_4, price: item_order_2.price, quantity: 4)

    visit '/'

    click_link "Login"
    expect(current_path).to eq('/login')

    fill_in :email, with: admin.email
    fill_in :password, with: admin.password

    click_button "Login"

    within "#order-#{order_2.id}" do
      expect(page).to have_link(order_2.name)
      expect(page).to have_content(order_2.id)
      expect(page).to have_content(order_2.created_at)
    end

    within "#order-pending" do
      expect(page).to have_link(order.name)
      expect(page).to have_content(order.id)
      expect(page).to have_content(order.created_at)
    end

    within "#order-shipped" do
      expect(page).to have_link(order_3.name)
      expect(page).to have_content(order_3.id)
      expect(page).to have_content(order_3.created_at)
    end

    within "#order-cancelled" do
      expect(page).to have_link(order_4.name)
      expect(page).to have_content(order_4.id)
      expect(page).to have_content(order_4.created_at)
    end

    click_on("#{order_4.name}")
    expect(current_path).to eql("/admin/profile/#{user_2.id}")
  end

  it "can ship packaged orders" do
    admin = create(:random_user, role: 1)
    user = create(:random_user, role: 0)
    user_2 = create(:random_user, role: 0)
    order_1 = create(:random_order, user_id: user.id, current_status: 1)
    order_2 = create(:random_order, user_id: user_2.id, current_status: 1)
    merchant = create(:random_merchant)
    item_1 = create(:random_item, merchant_id: merchant.id)
    item_2 = create(:random_item, merchant_id: merchant.id)
    item_order = ItemOrder.create!(item: item_1, order: order_1, price: item_1.price, quantity: 1, status: 1)
    item_order_2 = ItemOrder.create!(item: item_2, order: order_1, price: item_2.price, quantity: 2, status: 1)
    item_order_3 = ItemOrder.create!(item: item_1, order: order_2, price: item_1.price, quantity: 3, status: 1)
    item_order_4 = ItemOrder.create!(item: item_2, order: order_2, price: item_2.price, quantity: 4, status: 1)

    visit '/'
    click_link "Login"
    fill_in :email, with: admin.email
    fill_in :password, with: admin.password
    click_button "Login"

    within "#order-#{order_2.id}" do
      expect(page).to have_button "Ship Order"
    end

    within "#order-#{order_1.id}" do
        click_button "Ship Order"
    end

    visit "/admin"

    expect(page).not_to have_css("#order-#{order_1.id}")
    expect(page).to have_css("#order-#{order_2.id}")

    within "#order-shipped" do
      expect(page).to have_content(order_1.id)
      expect(page).to have_content(order_1.name)
      expect(page).to have_content(order_1.created_at)
    end
  end

  it 'has all user info and name is link to user show page' do
    admin = create(:random_user, role: 1)
    user = create(:random_user, role: 0)
    user_2 = create(:random_user, role: 0)

    visit '/'
    click_link "Login"
    expect(current_path).to eq('/login')

    fill_in :email, with: admin.email
    fill_in :password, with: admin.password

    click_button "Login"

    within 'nav' do
      click_link 'All Users'
    end

    expect(current_path).to eq("/admin/users")

    expect(page).to have_content(user.name)
    expect(page).to have_content(user_2.name)

    within "#users-#{user.id}" do
      click_link "#{user.name}"
    end

    expect(current_path).to eq("/admin/users/#{user.id}")
    visit "/admin/users"

    within "#users-#{user.id}" do
      expect(page).to have_content("User created at #{user.created_at}")
      expect(page).to have_content("default")
    end
  end
end
