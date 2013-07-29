require 'factory_girl'

FactoryGirl.define do
  factory :test_login_ticket, aliases:[:login_ticket] do
    sequence :ticket do |n|
      "LT-ticket#{n}"
    end

    trait :consumed do
      consumed true
    end

    trait :expired do
      lifetime = CASinoCore.config.login_ticket[:lifetime].seconds+1
      created_at lifetime.ago
    end
  end
end
