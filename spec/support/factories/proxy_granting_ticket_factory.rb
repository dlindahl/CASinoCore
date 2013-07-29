require 'factory_girl'

FactoryGirl.define do
  factory :test_proxy_granting_ticket, aliases:[:proxy_granting_ticket, :granter] do
    association :granter, factory: :test_service_ticket
    sequence :ticket do |n|
      "PGT-ticket#{n}"
    end
    sequence :iou do |n|
      "PGTIOU-ticket#{n}"
    end
    sequence :pgt_url do |n|
      "https://www#{n}.example.org/pgtUrl"
    end
  end
end
