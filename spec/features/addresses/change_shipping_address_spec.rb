require 'rails_helper'

describe 'As a user' do
  it 'I can select an address at checkout' do
    merchant = create(:user, :merchant)
    item = create(:item, user: merchant)
    user = create(:user_with_addresses)
    default_address = Address.first
    new_address = Address.last
    order = Order.create(status: 'pending',
                         user_id: user.id,
                         street: default_address.street,
                         city: default_address.city,
                         state: default_address.state,
                         zip: default_address.zip)

    visit login_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Log in'

    click_link "Orders"
    click_link "Order #{Order.last.id}"

    expect(page).to have_content(default_address.street)

    click_link "Change shipping address"

    choose(option: new_address.id)
    click_button "Update Address"
    click_link "Order #{Order.last.id}"

    expect(page).to have_content(new_address.street)
    expect(page).to have_content(new_address.city)
    expect(page).to have_content(new_address.state)
    expect(page).to have_content(new_address.zip)
    expect(page).to_not have_content(default_address.street)

  end
end

    