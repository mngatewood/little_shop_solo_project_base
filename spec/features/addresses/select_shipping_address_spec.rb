require 'rails_helper'

describe 'As a user' do
  it 'I can select an address at checkout' do
    merchant = create(:user, :merchant)
    item = create(:item, user: merchant)
    user = create(:user_with_addresses)
    address = Address.last

    visit login_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Log in'

    click_link 'Items'
    click_link item.name
    click_button 'Add to Cart'
    click_link 'Cart: 1'
    click_button 'Check out'

    choose(option: address.id)
    click_button "Submit Order"

    click_link "Order #{Order.last.id}"

    expect(page).to have_content(address.street)
    expect(page).to have_content(address.city)
    expect(page).to have_content(address.state)
    expect(page).to have_content(address.zip)

  end
end

    