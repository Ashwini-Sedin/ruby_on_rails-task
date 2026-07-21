FactoryBot.define do
  factory :user do
    name { "Teacher One" }
    email { Faker::Internet.unique.email }
    password { "password123" }
    role { "teacher" }
  end
end
