require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'
require 'casino_core/builder'

# The ServiceTicketValidator processor should be used to handle GET requests to /serviceValidate
class CASinoCore::Processor::ServiceTicketValidator < CASinoCore::Processor
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::ProxyGrantingTickets

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor. The Content-Type should be set to 'text/xml; charset=utf-8'
  #
  # @param [Hash] params parameters delivered by the client
  def process(params = nil)
    params ||= {}
    if request_valid?(params)
      ticket = CASinoCore.implementor(:service_ticket).find_ticket(params[:ticket])
      validate_ticket!(ticket, params)
    end
  end

  protected
  def build_service_response(success, options = {})
    builder = CASinoCore::Builder::TicketValidationResponse.new(success, options)
    builder.build
  end

  def request_valid?(params)
    if params[:ticket].nil? || params[:service].nil?
      @listener.validation_failed build_service_response(false, error_code: 'INVALID_REQUEST', error_message: '"ticket" and "service" parameters are both required')
      false
    else
      true
    end
  end

  def validate_ticket!(ticket, params)
    validation_result = validate_ticket_for_service(ticket, params[:service], !!params[:renew])
    if validation_result.success?
      options = { ticket: ticket }
      unless params[:pgtUrl].nil?
        options[:proxy_granting_ticket] = acquire_proxy_granting_ticket(params[:pgtUrl], ticket)
      end
      @listener.validation_succeeded(build_service_response(true, options))
    else
      @listener.validation_failed(build_service_response(false, error_code: validation_result.error_code, error_message: validation_result.error_message))
    end
  end
end
