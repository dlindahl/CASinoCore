require 'casino_core/processor'
require 'casino_core/helper'

# The CurrentUser processor returns the CASinoCore::Model::User instance for the currently signed in user.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASinoCore::Processor::CurrentUser < CASinoCore::Processor
  include CASinoCore::Helper::TicketGrantingTickets

  # This method will call `#user_not_logged_in` or `#current_user(CASinoCore::Model::User)` on the listener.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(cookies = nil, user_agent = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt
      @listener.current_user(tgt.user)
    else
      @listener.user_not_logged_in
    end
  end

end