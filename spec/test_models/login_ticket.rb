require 'casino_core/orm_compatibility/active_model'

class TestLoginTicket < ActiveRecord::Base
  include CASinoCore::Concerns::LoginTicket
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_login_tickets", :force => true do |t|
    t.string "ticket"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "test_login_tickets", ["ticket"], :name => "index_login_tickets_on_ticket", :unique => true
end