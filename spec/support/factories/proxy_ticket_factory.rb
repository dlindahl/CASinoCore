require 'factory_girl'

FactoryGirl.define do
  factory :test_proxy_ticket, aliases:[:proxy_ticket] do
    association :proxy_granting_ticket, factory: :test_proxy_granting_ticket

    sequence :ticket do |n|
      "PT-ticket#{n}"
    end
    sequence :service do |n|
      "imaps://mail#{n}.example.org/"
    end

    trait :consumed do
      consumed true
    end

    trait :expired do
      created_at { (lifetime+1).ago }
    end
  end
end
