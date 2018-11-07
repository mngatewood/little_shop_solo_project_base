FactoryBot.define do
  factory :user, class: User do

    trait :merchant do
      role { 1 }
    end
    
    trait :admin do
      role { 2 }
    end

    trait :inactive_user do
      role { 0 }
      active { false }
    end

    trait :inactive_merchant do
      role { 1 }
      active { false }
    end

    sequence(:email) { |n| "user_#{n}@gmail.com" }
    sequence(:password) { |n| "Password #{n}" }
    sequence(:name) { |n| "User #{n}" }
    role { 0 }
    active { true }

    factory :user_with_addresses do

      transient do
        addresses_count { 2 }
      end

      after(:create) do |user, evalulator|
        create(:address, :default, user: user)
        create_list(:address, evalulator.addresses_count - 1, user: user)
      end

    end
  end
end
