require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::TwoFactorAuthenticator
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:two_factor_authenticator] = self
  end

  module ClassMethods
    def cleanup
      delete_all_inactive_authenticators(self.lifetime.ago)
    end

    def lifetime
      CASinoCore.config.two_factor_authenticator[:lifetime_inactive].seconds
    end

    def delete_all_inactive_authenticators(lifetime)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :delete_all_inactive_authenticators ' \
                                  'method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :secret
      validates :secret, :user_id, presence: true
      belongs_to :user
    end

    module ClassMethods
      def delete_all_inactive_authenticators(lifetime)
        self.delete_all(['(created_at < ?) AND active = ?', lifetime, false])
      end
    end
  end

  def expired?
    !self.active? && (Time.now - (self.created_at || Time.now)) > self.class.lifetime
  end

  def lifetime
    self.class.lifetime
  end
end