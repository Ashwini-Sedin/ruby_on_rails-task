FactoryBot.define do
  factory :student do
    association :teacher, factory: :user

    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    age { 20 }
    course { "Ruby" }
    city { "Chennai" }
    marks { 80 }
  end
end
