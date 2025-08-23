FactoryBot.define do
  factory :transaction do
    description { "Test Transaction" }
    amount { 10.0 }
    category { "Test" }
    date { Date.today }
  end
end
