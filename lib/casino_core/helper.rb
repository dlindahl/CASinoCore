require 'logger'
require 'useragent'

module CASinoCore
  module Helper
    autoload :Authentication, 'casino_core/helper/authentication.rb'
    autoload :Browser, 'casino_core/helper/browser.rb'
    autoload :Logger, 'casino_core/helper/logger.rb'
    autoload :LoginTickets, 'casino_core/helper/login_tickets.rb'
    autoload :ProxyGrantingTickets, 'casino_core/helper/proxy_granting_tickets.rb'
    autoload :ProxyTickets, 'casino_core/helper/proxy_tickets.rb'
    autoload :ServiceTickets, 'casino_core/helper/service_tickets.rb'
    autoload :Tickets, 'casino_core/helper/tickets.rb'
    autoload :TicketGrantingTickets, 'casino_core/helper/ticket_granting_tickets.rb'
    autoload :TwoFactorAuthenticators, 'casino_core/helper/two_factor_authenticators.rb'
    autoload :Url, 'casino_core/helper/url.rb'
  end
end
