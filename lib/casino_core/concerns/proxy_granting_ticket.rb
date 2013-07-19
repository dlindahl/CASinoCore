require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::ProxyGrantingTicket
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:proxy_granting_ticket] = self
  end

  module ClassMethods
    def find_ticket(*args)
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :find_ticket method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :iou, :ticket, :pgt_url
      validates :pgt_url, :granter_id, :granter_type, presence:true
      validates :ticket, :iou, uniqueness: true, presence:true
      belongs_to :granter, polymorphic: true
      has_many :proxy_tickets, dependent: :destroy, foreign_key: :proxy_granting_ticket_id
    end

    module ClassMethods
      def find_ticket(*args)
        find_by_ticket(*args)
      end
    end

    def create_proxy_ticket!(params)
      proxy_tickets.create!(params)
    end
  end

  def create_proxy_ticket!(params)
    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :create_proxy_ticket! method'
  end
end