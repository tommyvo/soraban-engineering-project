FactoryBot.define do
  factory :csv_import do
    status { 'pending' }
    # Attachments (like csv) should be attached in the test, not the factory
  end
end
