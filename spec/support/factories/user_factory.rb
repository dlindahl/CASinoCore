require 'factory_girl'

FactoryGirl.define do
  factory :test_user, aliases:[:user] do
    authenticator 'test'
    sequence(:username) do |n|
      "test#{n}"
    end

    extra_attributes({ fullname: "Test User", age: 15, roles: [:user] })

    factory :user_with_two_factor_auth do
      ignore do
        auth_count 1
        active false
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(
          :two_factor_authenticator, evaluator.auth_count, user:user, active:evaluator.active
        )
      end
    end

    factory :user_with_ticket_granting_ticket do
      ignore do
        tickets 1
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(
          :ticket_granting_ticket, evaluator.tickets, user:user
        )
      end
    end
  end
end
