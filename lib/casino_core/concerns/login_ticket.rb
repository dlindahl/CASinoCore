require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::LoginTicket
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:login_ticket] = self
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

    def create(*args)
      return super if defined?(super)

      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :create method'
    end

    def find_ticket(*args)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :find_ticket method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :ticket
      validates :ticket, uniqueness: true, presence: true
    end

    module ClassMethods
      def delete_all_expired_tickets(lifetime)
        self.delete_all(['created_at < ?', lifetime])
      end

      def find_ticket(*args)
        find_by_ticket(*args)
      end
    end
  end
end