require 'casino_core/orm_compatibility/active_model'

class TestTicketGrantingTicket < ActiveRecord::Base
  include CASinoCore::Concerns::TicketGrantingTicket
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_ticket_granting_tickets", :force => true do |t|
    t.string   "ticket",                                                :null => false
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "user_agent"
    t.integer  "user_id",                                               :null => false
    t.boolean  "awaiting_two_factor_authentication", :default => false, :null => false
    t.boolean  "long_term",                          :default => false, :null => false
  end

  add_index "test_ticket_granting_tickets", ["ticket"], :name => "index_ticket_granting_tickets_on_ticket", :unique => true
end