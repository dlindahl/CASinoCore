require 'casino_core'
require 'rails'

module CASinoCore
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'casino_core/tasks'
    end

    initializer 'casino_core.setup_logger' do
      CASinoCore.config.logger = Rails.logger
    end
  end
end
