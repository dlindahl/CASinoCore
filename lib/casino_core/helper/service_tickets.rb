module CASinoCore
  module Helper
    module ServiceTickets
      include CASinoCore::Helper::Url
      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets
      include CASinoCore::Helper::ProxyTickets

      def acquire_service_ticket(ticket_granting_ticket, service, credentials_supplied = nil)
        service_url = clean_service_url(service)
        unless CASinoCore.implementor(:service_rule).allowed?(service_url)
          message = "#{service_url} is not in the list of allowed URLs"
          logger.error message
          raise ServiceNotAllowedError, message
        end
        ticket_granting_ticket.create_service_ticket!({
          ticket: random_ticket_string('ST'),
          service: service_url,
          issued_from_credentials: !!credentials_supplied
        })
      end

    end
  end
end
