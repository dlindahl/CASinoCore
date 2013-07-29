require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::TicketGrantingTicket
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:ticket_granting_ticket] = self
  end

  module ClassMethods
    def cleanup(user = nil)
      tickets = if user.nil?
        self
      else
        user.ticket_granting_tickets
      end

      delete_all_expired_tickets(tickets)
    end

    def create!(params)
      return super if defined?(super)

      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :create! method'
    end

    def delete_expired_two_factor_tickets(tickets)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :delete_expired_two_factor_tickets ' \
                                  'method'
    end

    def delete_expired_short_term_tickets(tickets)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :delete_expired_short_term_tickets ' \
                                  'method'
    end

    def delete_expired_long_term_tickets(tickets)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :delete_expired_long_term_tickets ' \
                                  'method'
    end

    def delete_all_expired_tickets(tickets)
      delete_expired_two_factor_tickets(tickets)
      delete_expired_short_term_tickets(tickets)
      delete_expired_long_term_tickets(tickets)
    end

    def find_ticket(*args)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :find_ticket method'
    end

    def find_id(*args)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :find_id method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :ticket, :user_agent, :awaiting_two_factor_authentication, :long_term
      validates :user_id, presence: true
      validates :ticket, uniqueness: true, presence: true
      belongs_to :user
      has_many :service_tickets, dependent: :destroy, foreign_key: :ticket_granting_ticket_id
    end

    module ClassMethods
      def delete_expired_two_factor_tickets(tickets)
        tickets.where([
          'created_at < ? AND awaiting_two_factor_authentication = ?',
          CASinoCore.config.two_factor_authenticator[:timeout].seconds.ago,
          true
        ]).delete_all
      end

      def delete_expired_short_term_tickets(tickets)
        tickets.where([
          'created_at < ? AND long_term = ?',
          CASinoCore.config.ticket_granting_ticket[:lifetime].seconds.ago,
          false
        ]).delete_all
      end

      def delete_expired_long_term_tickets(tickets)
        tickets.where([
          'created_at < ? AND long_term = ?',
          CASinoCore.config.ticket_granting_ticket[:lifetime_long_term].seconds.ago,
          true
        ]).delete_all
      end

      def find_ticket(*args)
        find_by_ticket(*args)
      end

      def find_id(*args)
        find_by_id(*args)
      end
    end

    def create_service_ticket!(params)
      service_tickets.create! params
    end
  end

  def create_service_ticket!(params)
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :create_service_ticket! method'
  end

  def browser_info
    return if user_agent.blank?

    ua = UserAgent.parse(user_agent)
    ua.browser.tap do |str|
      str << " (#{ua.platform})" if ua.platform
    end
  end

  def same_user?(other_ticket)
    if other_ticket.nil?
      false
    else
      other_ticket.user_id == self.user_id
    end
  end

  def expired?
    (Time.now - (self.created_at || Time.now)) > lifetime
  end

  def lifetime
    if awaiting_two_factor_authentication
      CASinoCore.config.two_factor_authenticator[:timeout]
    elsif long_term
      CASinoCore.config.ticket_granting_ticket[:lifetime_long_term]
    else
      CASinoCore.config.ticket_granting_ticket[:lifetime]
    end
  end
end
