FactoryBot.define do
  factory :borrowed_book do
    association :book
    association :user
    status { :borrowed }
  end
end
