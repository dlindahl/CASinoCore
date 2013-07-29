require 'factory_girl'

FactoryGirl.define do
  factory :test_ticket_granting_ticket, aliases:[:ticket_granting_ticket] do
    association :user, factory: :test_user
    sequence :ticket do |n|
      "TGC-ticket#{n}"
    end
    user_agent 'TestBrowser 1.0'

    trait :awaiting_two_factor_authentication do
      awaiting_two_factor_authentication true
    end

    trait :long_term do
      long_term true
    end

    trait :expired do
      created_at { (lifetime+1).ago }
    end
  end
end
