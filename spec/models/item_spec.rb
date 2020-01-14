require 'rails_helper'

describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_presence_of :image }
    it { should validate_presence_of :inventory }
    it { should validate_inclusion_of(:active?).in_array([true,false]) }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :reviews}
    it {should have_many :item_orders}
    it {should have_many(:orders).through(:item_orders)}
  end

  describe "model methods" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)

      @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5)
      @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4)
      @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1)
      @review_4 = @chain.reviews.create(title: "Not too impressed", content: "v basic bike shop", rating: 2)
      @review_5 = @chain.reviews.create(title: "Okay place :/", content: "Brian's cool and all but just an okay selection of items", rating: 3)

      @user = create(:random_user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "calculate average review" do
      expect(@chain.average_review).to eq(3.0)
    end

    it "sorts reviews" do
      top_three = @chain.sorted_reviews(3,:desc)
      bottom_three = @chain.sorted_reviews(3,:asc)

      expect(top_three).to eq([@review_1,@review_2,@review_5])
      expect(bottom_three).to eq([@review_3,@review_4,@review_5])
    end

    it 'no orders' do
      expect(@chain.no_orders?).to eq(true)
      order = @user.orders.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      order.item_orders.create(item: @chain, price: @chain.price, quantity: 2)
      expect(@chain.no_orders?).to eq(false)
    end

    it "discountable?" do
      other_merchant = create(:random_merchant)
      item = create(:random_item, price: 10, merchant_id: other_merchant.id)

      # item_hash = {item => 1, @chain => 1}

      coupon_1 = @bike_shop.coupons.create(name: 'Half off summer sale!',
                                           code: 'summersale',
                                           value_off: 50)

      coupon_2 = other_merchant.coupons.create(name: 'New member sale',
                                               code: 'welcome10',
                                               value_off: 10)

      expect(item.discountable?(coupon_2)).to be_truthy
      expect(item.discountable?(coupon_1)).to_not be_truthy

      expect(@chain.discountable?(coupon_1)).to be_truthy
      expect(@chain.discountable?(coupon_2)).to_not be_truthy
    end

    it "discounted_price" do
      other_merchant = create(:random_merchant)
      item = create(:random_item, price: 10, merchant_id: other_merchant.id)

      coupon_1 = @bike_shop.coupons.create(name: 'Half off summer sale!',
                                           code: 'summersale',
                                           value_off: 50)

      coupon_2 = other_merchant.coupons.create(name: 'New member sale',
                                               code: 'welcome10',
                                               value_off: 10)

      expect(item.discounted_price(coupon_2)).to eq(9)
    end

    describe "most_popular" do
      it "can find five most popular items" do
        item_1 = create(:random_item, merchant_id: @bike_shop.id)
        item_2 = create(:random_item, merchant_id: @bike_shop.id)
        item_3 = create(:random_item, merchant_id: @bike_shop.id)
        item_4 = create(:random_item, merchant_id: @bike_shop.id)
        item_5 = create(:random_item, merchant_id: @bike_shop.id)
        item_6 = create(:random_item, merchant_id: @bike_shop.id)

        order_1 = @user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)

        ItemOrder.create!(item: item_1, order: order_1, price: item_1.price, quantity: 5)
        ItemOrder.create!(item: item_2, order: order_1, price: item_2.price, quantity: 3)
        ItemOrder.create!(item: item_3, order: order_1, price: item_3.price, quantity: 9)
        ItemOrder.create!(item: item_4, order: order_1, price: item_4.price, quantity: 4)
        ItemOrder.create!(item: item_5, order: order_1, price: item_5.price, quantity: 2)
        ItemOrder.create!(item: item_6, order: order_1, price: item_6.price, quantity: 7)

        expect(Item.popularity('desc')[0]).to eq(item_3)
        expect(Item.popularity('desc')[1]).to eq(item_6)
        expect(Item.popularity('desc')[2]).to eq(item_1)
        expect(Item.popularity('desc')[3]).to eq(item_4)
        expect(Item.popularity('desc')[4]).to eq(item_2)
      end
    end

    describe "least_popular" do
      it "can find five least popular items" do
        item_1 = create(:random_item, merchant_id: @bike_shop.id)
        item_2 = create(:random_item, merchant_id: @bike_shop.id)
        item_3 = create(:random_item, merchant_id: @bike_shop.id)
        item_4 = create(:random_item, merchant_id: @bike_shop.id)
        item_5 = create(:random_item, merchant_id: @bike_shop.id)
        item_6 = create(:random_item, merchant_id: @bike_shop.id)

        order_1 = @user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)

        ItemOrder.create!(item: item_1, order: order_1, price: item_1.price, quantity: 5)
        ItemOrder.create!(item: item_2, order: order_1, price: item_2.price, quantity: 3)
        ItemOrder.create!(item: item_3, order: order_1, price: item_3.price, quantity: 9)
        ItemOrder.create!(item: item_4, order: order_1, price: item_4.price, quantity: 4)
        ItemOrder.create!(item: item_5, order: order_1, price: item_5.price, quantity: 2)
        ItemOrder.create!(item: item_6, order: order_1, price: item_6.price, quantity: 7)

        expect(Item.popularity[0]).to eq(item_5)
        expect(Item.popularity[1]).to eq(item_2)
        expect(Item.popularity[2]).to eq(item_4)
        expect(Item.popularity[3]).to eq(item_1)
        expect(Item.popularity[4]).to eq(item_6)
      end
    end
    it '.toggle active status' do
      expect(@chain.active?).to eq(true)
      @chain.toggle_active_status
      expect(@chain.active?).to eq(false)
      @chain.toggle_active_status
      expect(@chain.active?).to eq(true)
      
    end
  end
end
