FactoryBot.define do
  factory :rule do
    field { "description" }
    operator { "contains" }
    value { "coffee" }
    category { "Food" }
    priority { 1 }
  end
end
