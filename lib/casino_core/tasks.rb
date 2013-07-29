# Polyfill Rails' standard :environment task.
# Non-Rails users will have to define their own :environment task that should
# be responsible for loading their app, ORM connection, and CASinoCore
# integration.
Rake::Task.define_task('environment')

Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }