require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The SessionDestroyer processor is used to destroy a ticket-granting ticket.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side. It is especially useful in
# combination with the {CASinoCore::Processor::SessionOverview} processor.
class CASinoCore::Processor::SessionDestroyer < CASinoCore::Processor

  include CASinoCore::Helper::Logger

  # This method will call `#ticket_not_found` or `#ticket_deleted` on the listener.
  # @param [Hash] params parameters supplied by user (ID of ticket-granting ticket to delete should by in params[:id])
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    ticket = CASinoCore.implementor(:ticket_granting_ticket).find_id(params[:id])
    owner_ticket = CASinoCore.implementor(:ticket_granting_ticket).find_ticket(cookies[:tgt])
    if ticket.nil? || !ticket.same_user?(owner_ticket)
      @listener.ticket_not_found
    else
      logger.info "Destroying ticket-granting ticket '#{ticket.ticket}'"
      ticket.destroy
      @listener.ticket_deleted
    end
  end
end
