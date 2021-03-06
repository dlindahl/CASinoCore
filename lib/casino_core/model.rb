require 'active_record'

module CASinoCore
  module Model
    autoload :LoginTicket, 'casino_core/model/login_ticket.rb'
    autoload :ServiceRule, 'casino_core/model/service_rule.rb'
    autoload :ServiceTicket, 'casino_core/model/service_ticket.rb'
    autoload :ProxyGrantingTicket, 'casino_core/model/proxy_granting_ticket.rb'
    autoload :ProxyTicket, 'casino_core/model/proxy_ticket.rb'
    autoload :TicketGrantingTicket, 'casino_core/model/ticket_granting_ticket.rb'
    autoload :TwoFactorAuthenticator, 'casino_core/model/two_factor_authenticator.rb'
    autoload :User, 'casino_core/model/user.rb'
    autoload :ValidationResult, 'casino_core/model/validation_result.rb'
  end
end
