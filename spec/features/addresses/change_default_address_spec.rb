require 'rails_helper'

describe 'As a user' do
  it 'I can change my default address' do
    user = create(:user_with_addresses)

    visit login_path
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    click_button 'Log in'

    click_on 'set as default'

    expect(current_path).to eq(profile_path)
    expect(page).to have_content("Address Nickname 2 (default)")
  end
end


