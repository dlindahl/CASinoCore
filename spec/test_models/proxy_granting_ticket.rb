require 'casino_core/orm_compatibility/active_model'

class TestProxyGrantingTicket < ActiveRecord::Base
  include CASinoCore::Concerns::ProxyGrantingTicket
end

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "test_proxy_granting_tickets", :force => true do |t|
    t.string   "ticket",       :null => false
    t.string   "iou",          :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "granter_id",   :null => false
    t.string   "pgt_url",      :null => false
    t.string   "granter_type", :null => false
  end

  add_index "test_proxy_granting_tickets", ["granter_type", "granter_id"], :name => "index_proxy_granting_tickets_on_granter_type_and_granter_id", :unique => true
  add_index "test_proxy_granting_tickets", ["iou"], :name => "index_proxy_granting_tickets_on_iou", :unique => true
  add_index "test_proxy_granting_tickets", ["ticket"], :name => "index_proxy_granting_tickets_on_ticket", :unique => true
end