require 'addressable/uri'
require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::ProxyTicket
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:proxy_ticket] = self
  end

  module ClassMethods
    def cleanup_unconsumed
      delete_all_expired_tickets :lifetime_unconsumed, false
    end

    def cleanup_consumed
      delete_all_expired_tickets :lifetime_consumed, true
    end

    def delete_all_expired_tickets(limetime, consumed)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :delete_all_expired_tickets ' \
                                  'method'
    end

    def find_ticket(*args)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :find_ticket method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :ticket, :service
      validates :service, :proxy_granting_ticket_id, presence: true
      validates :ticket, uniqueness: true, presence: true
      belongs_to :proxy_granting_ticket
      has_many :proxy_granting_tickets, as: :granter, dependent: :destroy, foreign_key: :proxy_granting_ticket_id
    end

    module ClassMethods
      def delete_all_expired_tickets(lifetime_type, consumed)
        lifetime_age = CASinoCore.config.proxy_ticket[lifetime_type].seconds.ago
        self.delete_all(['created_at < ? AND consumed = ?', lifetime_age, consumed])
      end

      def find_ticket(*args)
        find_by_ticket(*args)
      end
    end
  end

  def expired?
    (Time.now - (self.created_at || Time.now)) > lifetime
  end

  def lifetime
    lifetime_type = consumed ? :lifetime_consumed : :lifetime_unconsumed
    CASinoCore.config.proxy_ticket[lifetime_type]
  end
end
