require 'rails_helper'

describe Address, type: :model do
  describe 'Relationships' do

    it { should belong_to(:user) }

  end

  describe 'Validations' do

    it { should validate_presence_of :street }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
    it { should validate_presence_of :nickname }

  end
end