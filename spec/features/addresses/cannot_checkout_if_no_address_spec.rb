require 'rails_helper'

describe 'As a user' do
  it 'I can select an address at checkout' do
    merchant = create(:user, :merchant)
    item = create(:item, user: merchant)
    user = create(:user)

    visit login_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Log in'

    click_link 'Items'
    click_link item.name
    click_button 'Add to Cart'
    click_link 'Cart: 1'
    click_button 'Check out'

    expect(page).to have_content("You have no addresses saved.")
    expect(page).to have_content("Please add an address before checking out.")
    expect(page).to_not have_content("Submit Order")

    click_link "add an address"

    expect(current_path).to eq(new_user_address_path(user))
    expect(page).to have_content("Add an Address")

  end
end

    