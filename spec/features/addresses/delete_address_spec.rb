require 'rails_helper'

describe 'As a user' do
  it 'I can change my default address' do
    user = create(:user_with_addresses)
    address = Address.last

    visit login_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Log in'

    expect(page).to have_content("Address Nickname 2")

    within(".address-#{address.id}-container") do
      click_link 'delete'
    end

    expect(current_path).to eq(profile_path)
    expect(page).to_not have_content("Address Nickname 2")
  end
end


