require 'casino_core/orm_compatibility/active_model'

class TestServiceRule < ActiveRecord::Base
  include CASinoCore::Concerns::ServiceRule
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_service_rules", :force => true do |t|
    t.boolean  "enabled",    :default => true,  :null => false
    t.integer  "order",      :default => 10,    :null => false
    t.string   "name",                          :null => false
    t.string   "url",                           :null => false
    t.boolean  "regex",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "test_service_rules", ["url"], :name => "index_service_rules_on_url", :unique => true
end