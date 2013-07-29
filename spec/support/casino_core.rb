require 'active_support/core_ext/hash/deep_dup'

RSpec.configure do |config|
  config.before(:each) do
    @base_env = CASinoCore.env.dup

    CASinoCore.configure do |cfg|
      cfg.application_root = File.join(File.dirname(__FILE__),'..','..')
      cfg.logger.level = ::Logger::Severity::UNKNOWN
    end

    @base_config = CASinoCore.config.deep_dup


    CASinoCore.rebuild_associations!
  end

  config.after(:each) do
    CASinoCore.env = @base_env

    CASinoCore.config.clear
    CASinoCore.config.merge! @base_config
  end
end