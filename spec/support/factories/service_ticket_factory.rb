require 'factory_girl'

FactoryGirl.define do
  factory :test_service_ticket, aliases:[:service_ticket] do
    association :ticket_granting_ticket, factory: :test_ticket_granting_ticket

    sequence :ticket do |n|
      "ST-ticket#{n}"
    end
    sequence :service do |n|
      "http://www#{n}.example.org/"
    end

    trait :consumed do
      consumed true
    end

    trait :expired do
      created_at { (lifetime+1).ago }
    end

    trait :orphan do
      ticket_granting_ticket nil
    end

    factory :service_ticket_with_proxy_granting_ticket do
      ignore { ticket_count 1 }

      after(:create) do |service_ticket, evaluator|
        FactoryGirl.create_list(
          :test_proxy_granting_ticket, evaluator.ticket_count, granter:service_ticket
        )
      end
    end
  end
end
