require 'active_record'

module CASinoCore
  module Model
    autoload :ServiceRule, 'casino_core/model/service_rule.rb'
    autoload :TwoFactorAuthenticator, 'casino_core/model/two_factor_authenticator.rb'
    autoload :User, 'casino_core/model/user.rb'
    autoload :ValidationResult, 'casino_core/model/validation_result.rb'
  end
end
