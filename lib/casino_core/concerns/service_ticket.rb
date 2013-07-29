require 'active_support/concern'
require 'addressable/uri'

module CASinoCore::Concerns::ServiceTicket
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:service_ticket] = self
  end

  def destroy(*args)
    return super if defined?(super)

    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :destroy method'
  end

  module ClassMethods
    def cleanup_unconsumed
      delete_all_expired_tickets :lifetime_unconsumed, false
    end

    def cleanup_consumed(force = false)
      delete_all_expired_tickets :lifetime_consumed, true, force
    end

    def delete_all_expired_tickets(limetime, consumed, force = false)
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
      attr_accessible :ticket, :service, :issued_from_credentials
      validates :service, presence: true
      validates :ticket, uniqueness: true
      belongs_to :ticket_granting_ticket
      before_destroy :send_sso_notification, if: :consumed?
      has_many :proxy_granting_tickets, as: :granter, dependent: :destroy
    end

    module ClassMethods
      def delete_all_expired_tickets(lifetime_type, consumed, force = false)
        lifetime_age = CASinoCore.config.service_ticket[lifetime_type].seconds

        if lifetime_type == :lifetime_consumed
          if force
            lifetime_age = (lifetime_age * 2)
          else
            self.delete_all_ticket_orphans(consumed)
          end
        end

        self.delete_all(['created_at < ? AND consumed = ?', lifetime_age.ago, consumed])
      end

      def delete_all_ticket_orphans(consumed)
        self.delete_all(['ticket_granting_ticket_id IS NULL AND consumed = ?', consumed])
      end

      def find_ticket(*args)
        find_by_ticket(*args)
      end
    end
  end

  def service_with_ticket_url
    service_uri = Addressable::URI.parse(self.service)
    service_uri.query_values = (service_uri.query_values(Array) || []) << ['ticket', self.ticket]
    service_uri.to_s
  end

  def expired?
    (Time.now - (self.created_at || Time.now)) > lifetime
  end

  def lifetime
    lifetime_type = consumed ? :lifetime_consumed : :lifetime_unconsumed
    CASinoCore.config.service_ticket[lifetime_type]
  end

  def sso_notifier
    CASinoCore::Notifiers::SingleSignOutNotifier.new(self)
  end

  def send_sso_notification
    sso_notifier.notify

    # Don't let failed notifications halt any callback chain destruction
    true
  end
end
