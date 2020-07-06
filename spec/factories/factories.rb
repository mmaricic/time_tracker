FactoryBot.define do
  sequence :email do |n|
    "johndoe#{n}@mail.com"
  end
  
  factory :user do
    name {'John Doe'}
    email
    password {'password'}
  end

  factory :time_entry do
    start_time {Time.new(2020, 07, 01, 11, 00, 00, Time.zone)}
    end_time {Time.new(2020, 07, 01, 15, 00, 00, Time.zone)}
    association :user, factory: :user
  end
end