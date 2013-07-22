require 'builder'
require 'casino_core/processor'
require 'casino_core/helper'

# The ProxyTicketValidator processor should be used to handle GET requests to /proxyValidate
class CASinoCore::Processor::ProxyTicketValidator < CASinoCore::Processor::ServiceTicketValidator

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor. The Content-Type should be set to 'text/xml; charset=utf-8'
  #
  # @param [Hash] params parameters delivered by the client
  def process(params = nil)
    params ||= {}
    if request_valid?(params)
      class_name = if params[:ticket].start_with?('PT-')
        :proxy_ticket
      elsif params[:ticket].start_with?('ST-')
        :service_ticket
      end

      ticket = if class_name
        implementor = CASinoCore.config.implementors[class_name]
        implementor.find_ticket(params[:ticket])
      else
        nil
      end

      validate_ticket!(ticket, params)
    end
  end
end
