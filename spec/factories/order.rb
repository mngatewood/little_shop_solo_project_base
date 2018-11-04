FactoryBot.define do
  factory :order do
    user
    status { "pending" }
    street { "123 Main Street" }
    city { "Denver" }
    state { "CO" }
    zip { "80014" }
  end
  factory :completed_order, parent: :order do
    user
    status { "completed" }
    street { "123 Main Street" }
    city { "Denver" }
    state { "CO" }
    zip { "80014" }
  end
  factory :cancelled_order, parent: :order do
    user
    status { "cancelled" }
    street { "123 Main Street" }
    city { "Denver" }
    state { "CO" }
    zip { "80014" }
  end
  factory :disabled_order, parent: :order do
    user
    status { "disabled" }
    street { "123 Main Street" }
    city { "Denver" }
    state { "CO" }
    zip { "80014" }
  end
end
