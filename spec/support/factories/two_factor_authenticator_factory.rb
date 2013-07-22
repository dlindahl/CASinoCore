require 'factory_girl'
require 'rotp'

FactoryGirl.define do
  factory :test_two_factor_authenticator, aliases:[:two_factor_authenticator] do
    association :user, factory: :test_user
    secret { ROTP::Base32.random_base32 }
    active true

    trait :inactive do
      active false
    end

    trait :expired do
      created_at { (lifetime+1).ago }
    end
  end
end
