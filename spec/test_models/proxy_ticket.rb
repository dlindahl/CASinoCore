require 'casino_core/orm_compatibility/active_model'

class TestProxyTicket < ActiveRecord::Base
  include CASinoCore::Concerns::ProxyTicket
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_proxy_tickets", :force => true do |t|
    t.string   "ticket",                                      :null => false
    t.string   "service",                                     :null => false
    t.boolean  "consumed",                 :default => false, :null => false
    t.integer  "proxy_granting_ticket_id",                    :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "test_proxy_tickets", ["proxy_granting_ticket_id"], :name => "index_proxy_tickets_on_proxy_granting_ticket_id"
  add_index "test_proxy_tickets", ["ticket"], :name => "index_proxy_tickets_on_ticket", :unique => true
end