module CASinoCore
  module Concerns
    autoload :LoginTicket, 'casino_core/concerns/login_ticket.rb'
    autoload :ProxyGrantingTicket, 'casino_core/concerns/proxy_granting_ticket.rb'
    autoload :ProxyTicket, 'casino_core/concerns/proxy_ticket.rb'
    autoload :ServiceTicket, 'casino_core/concerns/service_ticket.rb'
    autoload :TicketGrantingTicket, 'casino_core/concerns/ticket_granting_ticket.rb'
  end
end