class Address < ApplicationRecord

  belongs_to :user

  validates_presence_of :street, :city, :state, :zip, :nickname

  # validates_uniqueness_of :default if :default

  def set_as_default(user)
    current_default = user.addresses.find_by(default: true)
    current_default.update_attribute :default, false
    update_attribute :default, true
  end

end