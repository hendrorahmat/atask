FactoryBot.define do

  sequence :email do |n|
    "example#{n}@example.com"
  end

  factory :user do
    username { generate :email }
    password { 'admin123' }
  end
end
