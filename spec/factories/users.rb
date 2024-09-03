FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    role { :borrower }
    api_key { "MyString" }
  end
end
