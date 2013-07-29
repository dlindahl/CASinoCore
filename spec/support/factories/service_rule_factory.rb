require 'factory_girl'

FactoryGirl.define do
  factory :test_service_rule, aliases:[:service_rule] do
    sequence :order do |n|
      n
    end
    sequence :name do |n|
      "Rule #{n}"
    end

    trait :regex do
      regex true
    end
  end
end
