FactoryBot.define do
  factory :cart do
    total_price { 0 }
    last_interaction_at { Time.current }
    abandoned_at { nil }
  end

  factory :shopping_cart, parent: :cart
end
