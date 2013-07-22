require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::User
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:user] = self
  end

  module ClassMethods
    def load_or_initialize(params = {})
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :load_or_initialize method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :authenticator, :username, :extra_attributes
      serialize :extra_attributes, Hash

      validates :authenticator, :username, presence: true

      has_many :ticket_granting_tickets, foreign_key: :user_id
      has_many :two_factor_authenticators, foreign_key: :user_id
    end

    module ClassMethods
      def load_or_initialize(params = {})
        where(params).first_or_initialize
      end
    end

    def active_two_factor_authenticators
      self.two_factor_authenticators.where(active: true)
    end

    def two_factor_authenticator(id)
      self.two_factor_authenticators.find_by_id(id)
    end

    def other_ticket_granting_tickets(id)
      ticket_granting_tickets.where('id != ?', id)
    end

    def authenticated_tickets
      ticket_granting_tickets.where(awaiting_two_factor_authentication: false)
        .order('updated_at DESC')
    end

    def delete_active_two_factor_authenticators
      active_two_factor_authenticators.delete_all
    end

    def create_two_factor_authenticator!(params)
      two_factor_authenticators.create!(params)
    end

    def create_ticket_granting_ticket!(params)
      ticket_granting_tickets.create!(params)
    end
  end

  def active_two_factor_authenticators
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :active_two_factor_authenticators method'
  end

  def two_factor_authenticator(id)
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :two_factor_authenticator method'
  end

  def other_ticket_granting_tickets(id)
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :other_ticket_granting_tickets method'
  end

  def authenticated_tickets
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :authenticated_tickets method'
  end

  def delete_active_two_factor_authenticators
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :delete_active_two_factor_authenticators method'
  end

  def create_two_factor_authenticator!(params)
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :create_two_factor_authenticator! method'
  end

  def create_ticket_granting_ticket!(params)
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :create_ticket_granting_ticket! method'
  end
end