require 'rails_helper'

describe 'As any kind of user' do
  describe 'when I visit the merchants index page' do
    before(:each) do
      @user, 
      @other_user = create_list(:user, 2)
      create(:address, :denver, user: @user)
      create(:address, :default, city: 'Dallas', state: 'TX', user: @other_user)

      @merchant_1, 
      @merchant_2,
      @merchant_3,
      @merchant_4,
      @merchant_5,
      @merchant_6,
      @merchant_7,
      @merchant_8,
      @merchant_9,
      @merchant_10,
      @merchant_11,
      @merchant_12,
      @merchant_13,
      @merchant_14 = create_list(:user, 14, :merchant)
      @merchant_15 = create(:user, :inactive_merchant)

      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)
      @item_3 = create(:item, user: @merchant_3)
      @item_4 = create(:item, user: @merchant_4)
      @item_5 = create(:item, user: @merchant_5)
      @item_6 = create(:item, user: @merchant_6)
      @item_7 = create(:item, user: @merchant_7)
      @item_8 = create(:item, user: @merchant_8)
      @item_9 = create(:item, user: @merchant_9)
      @item_10 = create(:item, user: @merchant_10)
      @item_11 = create(:item, user: @merchant_11)
      @item_12 = create(:item, user: @merchant_12)
      @item_13 = create(:item, user: @merchant_13)
      @item_14 = create(:item, user: @merchant_14)
      @item_15 = create(:item, user: @merchant_15)

      @order_1,
      @order_2,
      @order_3,
      @order_4,
      @order_5 = create_list(:completed_order, 5, user: @user)
      @order_6,
      @order_7,
      @order_8,
      @order_9,
      @order_10 = create_list(:completed_order_elsewhere, 5, user: @other_user)
      @order_11,
      @order_12 = create_list(:completed_order, 2, user: @user)
      @order_13 = create(:cancelled_order, user: @user)
      @order_14 = create(:order, user: @user)
      @order_15 = create(:completed_order, user: @user)

      create(:fulfilled_order_item, quantity: 10, order: @order_1, item: @item_1)
      create(:fulfilled_order_item, quantity: 11, order: @order_2, item: @item_2)
      create(:fulfilled_order_item, quantity: 12, order: @order_3, item: @item_3)
      create(:fulfilled_order_item, quantity: 13, order: @order_4, item: @item_4)
      create(:fulfilled_order_item, quantity: 14, order: @order_5, item: @item_5)
      create(:fulfilled_order_item, quantity: 15, order: @order_6, item: @item_6)
      create(:fulfilled_order_item, quantity: 16, order: @order_7, item: @item_7)
      create(:fulfilled_order_item, quantity: 17, order: @order_8, item: @item_8)
      create(:fulfilled_order_item, quantity: 18, order: @order_9, item: @item_9)
      create(:fulfilled_order_item, quantity: 19, order: @order_10, item: @item_10)
      create(:fulfilled_order_item, quantity: 1, order: @order_11, item: @item_11)
      create(:fulfilled_order_item, quantity: 100, order: @order_12, item: @item_12, updated_at: '1/1/2000')
      create(:fulfilled_order_item, quantity: 100, order: @order_13, item: @item_13)
      create(:order_item, quantity: 100, order: @order_14, item: @item_14)
      create(:fulfilled_order_item, quantity: 100, order: @order_15, item: @item_15)

      visit merchants_path
    end

    it 'should display top ten sellers and fulfillers' do
      expect(page).to have_content("Top Sellers")
      expect(page).to have_content("Top Fulfillers")

      within("ul.stats-top-sellers") do
        expect(page).to have_content(@merchant_13.name)
        expect(page).to have_content(@merchant_14.name)
        expect(page).to_not have_content(@merchant_1.name)
        expect(page).to_not have_content(@merchant_2.name)
      end
      
      within("ul.stats-top-fulfillers") do
        expect(page).to have_content(@merchant_1.name)
        expect(page).to have_content(@merchant_2.name)
        expect(page).to_not have_content(@merchant_13.name)
        expect(page).to_not have_content(@merchant_14.name)
      end
    end
     
    it 'should display top sellers in my city and state when logged in as a user' do

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button 'Log in'
      visit merchants_path
      
      expect(page).to have_content("Top Sellers for #{@user.default_address.state}")
      expect(page).to have_content("Top Sellers for #{@user.default_address.state}")

      within("ul.stats-top-sellers-state") do
        expect(page).to have_content(@merchant_5.name)
        expect(page).to have_content(@merchant_4.name)
        expect(page).to_not have_content(@merchant_6.name)
        expect(page).to_not have_content(@merchant_7.name)
      end
          
      within("ul.stats-top-sellers-city") do
        expect(page).to have_content(@merchant_5.name)
        expect(page).to have_content(@merchant_4.name)
        expect(page).to_not have_content(@merchant_6.name)
        expect(page).to_not have_content(@merchant_7.name)
      end

    end
  end
end