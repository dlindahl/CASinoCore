require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::LoginTicket
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility
  end

  def to_s
    self.ticket
  end

  module ClassMethods
    def cleanup
      delete_all_expired_tickets(CASinoCore.config.login_ticket[:lifetime].seconds.ago)
    end

    def delete_all_expired_tickets(lifetime)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :delete_all_expired_tickets ' \
                                  'method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :ticket
      validates :ticket, uniqueness: true
    end

    module ClassMethods
      def delete_all_expired_tickets(lifetime)
        self.delete_all(['created_at < ?', lifetime])
      end
    end
  end
end