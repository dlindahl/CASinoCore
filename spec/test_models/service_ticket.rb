require 'casino_core/orm_compatibility/active_model'

class TestServiceTicket < ActiveRecord::Base
  include CASinoCore::Concerns::ServiceTicket
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_service_tickets", :force => true do |t|
    t.string   "ticket",                                       :null => false
    t.string   "service",                                      :null => false
    t.integer  "ticket_granting_ticket_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "consumed",                  :default => false, :null => false
    t.boolean  "issued_from_credentials",   :default => false, :null => false
  end

  add_index "test_service_tickets", ["ticket"], :name => "index_service_tickets_on_ticket", :unique => true
  add_index "test_service_tickets", ["ticket_granting_ticket_id"], :name => "index_service_tickets_on_ticket_granting_ticket_id"
end