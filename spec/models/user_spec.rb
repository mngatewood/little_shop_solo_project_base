require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Relationships' do
    it { should have_many(:orders) }
    it { should have_many(:items) }
    it { should have_many(:addresses)}
  end

  describe 'Validations' do 
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
  end

  describe 'Class Methods' do
    it '.top_merchants(quantity)' do
      user = create(:user_with_addresses)
      merchant_1, merchant_2, merchant_3, merchant_4 = create_list(:user, 4, :merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_1, price: 20000, quantity: 1)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2000, quantity: 1)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_3, price: 200000, quantity: 1)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_4, price: 200, quantity: 1)

      expect(User.top_merchants(4)).to eq([merchant_3, merchant_1, merchant_2, merchant_4])
    end
    it '.popular_merchants(quantity)' do
      user = create(:user_with_addresses)
      merchant_1, merchant_2, merchant_3, merchant_4 = create_list(:user, 4, :merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)

      order = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)

      expect(User.popular_merchants(3)).to eq([merchant_2, merchant_1, merchant_3])
    end
    context 'merchants by speed' do
      before(:each) do
        user = create(:user_with_addresses)
        @merchant_1, @merchant_2, @merchant_3, @merchant_4 = create_list(:user, 4, :merchant)
        item_1 = create(:item, user: @merchant_1)
        item_2 = create(:item, user: @merchant_2)
        item_3 = create(:item, user: @merchant_3)
        item_4 = create(:item, user: @merchant_4)

        order = create(:order, user: user)
        create(:fulfilled_order_item, order: order, item: item_1, created_at: 1.year.ago)
        create(:fulfilled_order_item, order: order, item: item_2, created_at: 10.days.ago)
        create(:order_item, order: order, item: item_3, price: 3, quantity: 1)
        create(:fulfilled_order_item, order: order, item: item_4, created_at: 3.seconds.ago)
      end
      it '.fastest_merchants(quantity)' do
        expect(User.fastest_merchants(4)).to eq([@merchant_4, @merchant_2, @merchant_1, @merchant_3])
      end
      it '.slowest_merchants(quantity)' do
        expect(User.slowest_merchants(4)).to eq([@merchant_3, @merchant_1, @merchant_2, @merchant_4])
      end
    end
  end

  describe 'Instance Methods' do 
    it '.merchant_items' do
      user = create(:user_with_addresses)
      merchant = create(:user, :merchant)
      item_1, item_2, item_3, item_4, item_5 = create_list(:item, 5, user: merchant)
      
      order_1 = create(:order, user: user)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)
  
      order_2 = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order_2, item: item_2)
      create(:fulfilled_order_item, order: order_2, item: item_3)

      expect(merchant.merchant_orders).to eq([order_1, order_2])
    end
    it '.merchant_items(:pending)' do
      user = create(:user_with_addresses)
      merchant = create(:user, :merchant)
      item_1, item_2, item_3, item_4, item_5 = create_list(:item, 5, user: merchant)
      
      order_1 = create(:order, user: user)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)
  
      order_2 = create(:completed_order, user: user)
      create(:fulfilled_order_item, order: order_2, item: item_2)
      create(:fulfilled_order_item, order: order_2, item: item_3)

      expect(merchant.merchant_orders(:pending)).to eq([order_1])
    end
    it '.merchant_for_order(order)' do 
      user = create(:user_with_addresses)
      merchant_1, merchant_2 = create_list(:user, 2, :merchant)
      item_1, item_2 = create_list(:item, 5, user: merchant_1)
      item_3, item_4 = create_list(:item, 5, user: merchant_2)
      
      order_1 = create(:order, user: user)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)
  
      order_2 = create(:order, user: user)
      create(:order_item, order: order_2, item: item_3)
      create(:order_item, order: order_2, item: item_4)

      expect(merchant_1.merchant_for_order(order_1)).to eq(true)
      expect(merchant_1.merchant_for_order(order_2)).to eq(false)
    end
    it '.total_items_sold' do
      user = create(:user_with_addresses)
      merchant_1, merchant_2 = create_list(:user, 2, :merchant)
      item_1, item_2 = create_list(:item, 5, user: merchant_1)
      item_3, item_4 = create_list(:item, 5, user: merchant_2)
      
      order_1 = create(:completed_order, status: :completed, user: user)
      oi_1 = create(:fulfilled_order_item, order: order_1, item: item_1)
      oi_2 = create(:fulfilled_order_item, order: order_1, item: item_3)
  
      order_2 = create(:order, user: user)
      oi_3 = create(:fulfilled_order_item, order: order_2, item: item_2)
      oi_4 = create(:order_item, order: order_2, item: item_4)

      expect(merchant_1.total_items_sold).to eq(oi_1.quantity + oi_3.quantity)
      expect(merchant_2.total_items_sold).to eq(oi_2.quantity)
    end
    it '.total_inventory' do
      merchant = create(:user, :merchant)
      item_1, item_2 = create_list(:item, 2, user: merchant)

      expect(merchant.total_inventory).to eq(item_1.inventory + item_2.inventory)
    end
    it '.top_3_shipping_states' do
      user_1, user_2, user_3, user_4 = create_list(:user, 4)
      create(:address, state: 'CO', user: user_1)
      create(:address, state: 'CA', user: user_2)
      create(:address, state: 'FL', user: user_3)
      create(:address, state: 'NY', user: user_4)

      merchant = create(:user, :merchant)
      item_1 = create(:item, user: merchant)

      # Colorado is 1st place
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # California is 2nd place
      order = create(:completed_order, user: user_2, state: 'CA')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, state: 'CA')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, state: 'CA')
      create(:fulfilled_order_item, order: order, item: item_1)
      # Sorry Florida
      order = create(:completed_order, user: user_3, state: 'FL')
      create(:fulfilled_order_item, order: order, item: item_1)
      # NY is 3rd place
      order = create(:completed_order, user: user_4, state: 'NY')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_4, state: 'NY')
      create(:fulfilled_order_item, order: order, item: item_1)

      expect(merchant.top_3_shipping_states).to eq(['CO', 'CA', 'NY'])
    end
    it '.top_3_shipping_cities' do
      user_1, user_2, user_3, user_4 = create_list(:user, 4)
      create(:address, city: 'Denver', user: user_1)
      create(:address, city: 'Houston', user: user_2)
      create(:address, city: 'Ottawa', user: user_3)
      create(:address, city: 'NYC', user: user_4)

      merchant = create(:user, :merchant)
      item_1 = create(:item, user: merchant)

      # Denver is 2nd place
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # Houston is 1st place
      order = create(:completed_order, user: user_2, city: 'Houston')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, city: 'Houston')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, city: 'Houston')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, city: 'Houston')
      create(:fulfilled_order_item, order: order, item: item_1)
      # Sorry Ottawa
      order = create(:completed_order, user: user_3, city: 'Ottawa')
      create(:fulfilled_order_item, order: order, item: item_1)
      # NYC is 3rd place
      order = create(:completed_order, user: user_4, city: 'NYC')
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_4, city: 'NYC')
      create(:fulfilled_order_item, order: order, item: item_1)

      expect(merchant.top_3_shipping_cities).to eq(['Houston', 'Denver', 'NYC'])
    end
    it '.top_active_user' do
      user_1, user_2 = create_list(:user, 2)
      create(:address, city: 'Denver', user: user_1)
      create(:address, city: 'Houston', user: user_2)
      merchant = create(:user, :merchant)
      item_1 = create(:item, user: merchant)

      # user 1 is in 2nd place
      order = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # user 2 is best to start
      order = create(:completed_order, user: user_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2)
      create(:fulfilled_order_item, order: order, item: item_1)

      expect(merchant.top_active_user).to eq(user_2)
      user_2.update(active: false)
      expect(merchant.top_active_user).to eq(user_1)
    end
    it '.biggest_order' do
      user_1, user_2 = create_list(:user, 2)
      create(:address, city: 'Denver', user: user_1)
      create(:address, city: 'Houston', user: user_2)
      merchant_1, merchant_2 = create_list(:user, 2, :merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)

      # user 1 is in 2nd place
      order_1 = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, quantity: 10, order: order_1, item: item_1)
      create(:fulfilled_order_item, order: order_1, item: item_2)
      # user 2 is best to start
      order_2 = create(:completed_order, user: user_2)
      create(:fulfilled_order_item, quantity: 100, order: order_2, item: item_1)
      create(:fulfilled_order_item, order: order_2, item: item_2)

      expect(merchant_1.biggest_order).to eq(order_2)

      create(:fulfilled_order_item, quantity: 1000, order: order_1, item: item_1)
      expect(merchant_1.biggest_order).to eq(order_1)
    end
    it '.top_buyers(3)' do 
      user_1, user_2, user_3 = create_list(:user, 3)
      create(:address, city: 'Denver', user: user_1)
      create(:address, city: 'Houston', user: user_2)
      create(:address, city: 'Atlanta', user: user_3)

      merchant_1, merchant_2 = create_list(:user, 2, :merchant)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)

      # user 1 is in 2nd place
      order_1 = create(:completed_order, user: user_1)
      create(:fulfilled_order_item, quantity: 100, price: 10, order: order_1, item: item_1)
      create(:fulfilled_order_item, quantity: 100, price: 10, order: order_1, item: item_2)
      # user 2 is 1st place
      order_2 = create(:completed_order, user: user_2)
      create(:fulfilled_order_item, quantity: 1000, price: 10, order: order_2, item: item_1)
      create(:fulfilled_order_item, quantity: 1000, price: 10, order: order_2, item: item_2)
      # user 3 in last place
      order_3 = create(:completed_order, user: user_3)
      create(:fulfilled_order_item, quantity: 10, price: 10, order: order_3, item: item_1)
      create(:fulfilled_order_item, quantity: 10, price: 10, order: order_3, item: item_2)

      expect(merchant_1.top_buyers(3)).to eq([user_2, user_1, user_3])
    end

    # top 10 merchants by items sold in past 30 days
    it 'self.top_sellers' do

      user = create(:user_with_addresses)

      merchant_1, 
      merchant_2,
      merchant_3,
      merchant_4,
      merchant_5,
      merchant_6,
      merchant_7,
      merchant_8,
      merchant_9,
      merchant_10,
      merchant_11,
      merchant_12,
      merchant_13,
      merchant_14 = create_list(:user, 14, :merchant)
      merchant_15 = create(:user, :inactive_merchant)

      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)
      item_5 = create(:item, user: merchant_5)
      item_6 = create(:item, user: merchant_6)
      item_7 = create(:item, user: merchant_7)
      item_8 = create(:item, user: merchant_8)
      item_9 = create(:item, user: merchant_9)
      item_10 = create(:item, user: merchant_10)
      item_11 = create(:item, user: merchant_11)
      item_12 = create(:item, user: merchant_12)
      item_13 = create(:item, user: merchant_13)
      item_14 = create(:item, user: merchant_14)
      item_15 = create(:item, user: merchant_15)

      order_1,
      order_2,
      order_3,
      order_4,
      order_5,
      order_6,
      order_7,
      order_8,
      order_9,
      order_10,
      order_11,
      order_12 = create_list(:completed_order, 12, user: user)
      order_13 = create(:cancelled_order, user: user)
      order_14 = create(:order, user: user)
      order_15 = create(:completed_order, user: user)

      # not a top seller (not in top 10)
      create(:fulfilled_order_item, quantity: 1, order: order_1, item: item_1)
      create(:fulfilled_order_item, quantity: 2, order: order_2, item: item_2)

      # top sellers
      create(:fulfilled_order_item, quantity: 12, order: order_3, item: item_3)
      create(:fulfilled_order_item, quantity: 13, order: order_4, item: item_4)
      create(:fulfilled_order_item, quantity: 14, order: order_5, item: item_5)
      create(:fulfilled_order_item, quantity: 15, order: order_6, item: item_6)
      create(:fulfilled_order_item, quantity: 16, order: order_7, item: item_7)
      create(:fulfilled_order_item, quantity: 17, order: order_8, item: item_8)
      create(:fulfilled_order_item, quantity: 18, order: order_9, item: item_9)
      create(:fulfilled_order_item, quantity: 19, order: order_10, item: item_10)

      # not a top seller (not in top 10)
      create(:fulfilled_order_item, quantity: 1, order: order_11, item: item_11)
      # not in last 30 days (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_12, item: item_12, updated_at: '1/1/2000')
      # cancelled order (include)
      create(:fulfilled_order_item, quantity: 20, order: order_13, item: item_13)
      # pending order item (include)
      create(:order_item, quantity: 21, order: order_14, item: item_14)
      # inactive merchant (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_15, item: item_15)

      top_merchants = [ merchant_14,
                        merchant_13,
                        merchant_10,
                        merchant_9,
                        merchant_8,
                        merchant_7,
                        merchant_6,
                        merchant_5,
                        merchant_4,
                        merchant_3 ]

      expect(User.top_sellers).to eq(top_merchants)
      
    end

    # top 10 merchants by items fulfilled in past 30 days
    it 'self.top_fulfillers' do

      user = create(:user_with_addresses)

      merchant_1, 
      merchant_2,
      merchant_3,
      merchant_4,
      merchant_5,
      merchant_6,
      merchant_7,
      merchant_8,
      merchant_9,
      merchant_10,
      merchant_11,
      merchant_12,
      merchant_13,
      merchant_14 = create_list(:user, 14, :merchant)
      merchant_15 = create(:user, :inactive_merchant)

      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)
      item_5 = create(:item, user: merchant_5)
      item_6 = create(:item, user: merchant_6)
      item_7 = create(:item, user: merchant_7)
      item_8 = create(:item, user: merchant_8)
      item_9 = create(:item, user: merchant_9)
      item_10 = create(:item, user: merchant_10)
      item_11 = create(:item, user: merchant_11)
      item_12 = create(:item, user: merchant_12)
      item_13 = create(:item, user: merchant_13)
      item_14 = create(:item, user: merchant_14)
      item_15 = create(:item, user: merchant_15)

      order_1,
      order_2,
      order_3,
      order_4,
      order_5,
      order_6,
      order_7,
      order_8,
      order_9,
      order_10,
      order_11,
      order_12 = create_list(:completed_order, 12, user: user)
      order_13 = create(:cancelled_order, user: user)
      order_14 = create(:order, user: user)
      order_15 = create(:completed_order, user: user)

      # top sellers
      create(:fulfilled_order_item, quantity: 10, order: order_1, item: item_1)
      create(:fulfilled_order_item, quantity: 11, order: order_2, item: item_2)
      create(:fulfilled_order_item, quantity: 12, order: order_3, item: item_3)
      create(:fulfilled_order_item, quantity: 13, order: order_4, item: item_4)
      create(:fulfilled_order_item, quantity: 14, order: order_5, item: item_5)
      create(:fulfilled_order_item, quantity: 15, order: order_6, item: item_6)
      create(:fulfilled_order_item, quantity: 16, order: order_7, item: item_7)
      create(:fulfilled_order_item, quantity: 17, order: order_8, item: item_8)
      create(:fulfilled_order_item, quantity: 18, order: order_9, item: item_9)
      create(:fulfilled_order_item, quantity: 19, order: order_10, item: item_10)

      # not a top seller (not in top 10)
      create(:fulfilled_order_item, quantity: 1, order: order_11, item: item_11)
      # not in last 30 days (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_12, item: item_12, updated_at: '1/1/2000')
      # cancelled order (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_13, item: item_13)
      # pending order item (do not include)
      create(:order_item, quantity: 100, order: order_14, item: item_14)
      # inactive merchant (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_15, item: item_15)

      top_merchants = [ merchant_10,
                        merchant_9,
                        merchant_8,
                        merchant_7,
                        merchant_6,
                        merchant_5,
                        merchant_4,
                        merchant_3,
                        merchant_2,
                        merchant_1 ]

      expect(User.top_fulfillers).to eq(top_merchants)

    end

    # top 5 merchants by items sold in given city/state in past 30 days
    it 'self.top_fulfillers_my_region' do

      user, 
      other_user = create_list(:user, 2)
      create(:address, :denver, user: user)
      create(:address, :default, city: 'Dallas', state: 'TX', user: other_user)

      merchant_1, 
      merchant_2,
      merchant_3,
      merchant_4,
      merchant_5,
      merchant_6,
      merchant_7,
      merchant_8,
      merchant_9,
      merchant_10,
      merchant_11,
      merchant_12,
      merchant_13,
      merchant_14 = create_list(:user, 14, :merchant)
      merchant_15 = create(:user, :inactive_merchant)

      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)
      item_5 = create(:item, user: merchant_5)
      item_6 = create(:item, user: merchant_6)
      item_7 = create(:item, user: merchant_7)
      item_8 = create(:item, user: merchant_8)
      item_9 = create(:item, user: merchant_9)
      item_10 = create(:item, user: merchant_10)
      item_11 = create(:item, user: merchant_11)
      item_12 = create(:item, user: merchant_12)
      item_13 = create(:item, user: merchant_13)
      item_14 = create(:item, user: merchant_14)
      item_15 = create(:item, user: merchant_15)

      order_1,
      order_2,
      order_3,
      order_4,
      order_5 = create_list(:completed_order, 5, user: user)
      order_6,
      order_7,
      order_8,
      order_9,
      order_10 = create_list(:completed_order_elsewhere, 5, user: other_user)
      order_11,
      order_12 = create_list(:completed_order, 2, user: user)
      order_13 = create(:cancelled_order, user: user)
      order_14 = create(:order, user: user)
      order_15 = create(:completed_order, user: user)

      # top sellers in region
      create(:fulfilled_order_item, quantity: 10, order: order_1, item: item_1)
      create(:fulfilled_order_item, quantity: 11, order: order_2, item: item_2)
      create(:fulfilled_order_item, quantity: 12, order: order_3, item: item_3)
      create(:fulfilled_order_item, quantity: 13, order: order_4, item: item_4)
      create(:fulfilled_order_item, quantity: 14, order: order_5, item: item_5)

      # sellers outside region (do not include)
      create(:fulfilled_order_item, quantity: 15, order: order_6, item: item_6)
      create(:fulfilled_order_item, quantity: 16, order: order_7, item: item_7)
      create(:fulfilled_order_item, quantity: 17, order: order_8, item: item_8)
      create(:fulfilled_order_item, quantity: 18, order: order_9, item: item_9)
      create(:fulfilled_order_item, quantity: 19, order: order_10, item: item_10)

      # not a top seller (not in top 10)
      create(:fulfilled_order_item, quantity: 1, order: order_11, item: item_11)
      # not in last 30 days (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_12, item: item_12, updated_at: '1/1/2000')
      # cancelled order (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_13, item: item_13)
      # pending order item (do not include)
      create(:order_item, quantity: 100, order: order_14, item: item_14)
      # inactive merchant (do not include)
      create(:fulfilled_order_item, quantity: 100, order: order_15, item: item_15)

      top_merchants = [ merchant_5,
                        merchant_4,
                        merchant_3,
                        merchant_2,
                        merchant_1 ]

      expect(User.top_fulfillers_my_region(:city, user)).to eq(top_merchants)
      expect(User.top_fulfillers_my_region(:state, user)).to eq(top_merchants)

    end
  end
end
