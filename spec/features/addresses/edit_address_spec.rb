require 'rails_helper'

describe 'As a user' do
  it 'I can edit an address' do
    user = create(:user_with_addresses)
    address = Address.last

    visit login_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Log in'

    within(".address-#{address.id}-container") do
      click_link 'edit'
    end

    fill_in 'Nickname', with: 'work'
    fill_in 'Street', with: '123 Main Street'
    fill_in 'City', with: 'Denver'
    fill_in 'State', with: 'CO'
    fill_in 'Zip', with: '80015'
    click_button 'Update Address'

    expect(current_path).to eq(profile_path)
    expect(page).to have_content("Address updated.")
    expect(page).to have_content("123 Main Street")
  end
end


