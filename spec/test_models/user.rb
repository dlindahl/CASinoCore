require 'casino_core/orm_compatibility/active_model'

class TestUser < ActiveRecord::Base
  include CASinoCore::Concerns::User
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_users", :force => true do |t|
    t.string   "authenticator",    :null => false
    t.string   "username",         :null => false
    t.text     "extra_attributes"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "test_users", ["authenticator", "username"], :name => "index_users_on_authenticator_and_username", :unique => true
end