root_path   = File.join(File.dirname(__FILE__),'..','..')
schema_path = File.join(root_path, 'db')

CASinoCore.send(:establish_connection)
load File.join(schema_path, 'schema.rb')