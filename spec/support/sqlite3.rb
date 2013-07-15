require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:',
  verbosity: 'quiet'
)

ActiveRecord::Schema.define(:version => Time.now.to_i) do
  create_table "models", :force => true do |t|
    t.string "ticket" # include this?
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
end