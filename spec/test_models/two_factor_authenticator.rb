require 'casino_core/orm_compatibility/active_model'

class TestTwoFactorAuthenticator < ActiveRecord::Base
  include CASinoCore::Concerns::TwoFactorAuthenticator
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_two_factor_authenticators", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "secret",                        :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "active",     :default => false, :null => false
  end

  add_index "test_two_factor_authenticators", ["user_id"], :name => "index_two_factor_authenticators_on_user_id"
end