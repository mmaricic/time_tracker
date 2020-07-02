FactoryBot.define do
  sequence :email do |n|
    "johndoe#{n}@mail.com"
  end
  
  factory :user do
    name {'John Doe'}
    email
    password {'password'}
  end
end