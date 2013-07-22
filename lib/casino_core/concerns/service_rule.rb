require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::ServiceRule
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:service_rule] = self
  end

  module ClassMethods
    def allowed?(service_url)
      rules = enabled_rules
      return true if rules.empty?

      rules.any? { |rule| rule.allows?(service_url) }
    end

    def enabled_rules
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :enabled_rules method'
    end
  end

  module ActiveModelCompatibility
    extend ActiveSupport::Concern

    included do
      attr_accessible :enabled, :order, :name, :url, :regex
      validates :name, presence: true
      validates :url, uniqueness: true, presence: true
    end

    module ClassMethods
      def enabled_rules
        where(enabled: true)
      end
    end
  end

  def allows?(service_url)
    if self.regex.blank?
      self.url == service_url
    else
      Regexp.new(url, true) =~ service_url
    end
  end
end
