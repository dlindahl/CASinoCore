require 'active_support/concern'
require 'casino_core/concerns'

module CASinoCore::Concerns::ServiceRule
  extend ActiveSupport::Concern

  included do
    include_casino_core_orm_compatibility

    CASinoCore.config.implementors[:service_rule] = self
  end

  module ClassMethods
    include CASinoCore::Helper::Url

    def allowed?(service_url)
      rules = enabled_rules
      return true if rules.empty?

      rules.any? { |rule| rule.allows?(service_url) }
    end

    def enabled_rules
      raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                  'not defined a :enabled_rules method'
    end

    # Adds a service rule (prefix the url parameter with "regex:" to add a regular expression)
    def add(name, url)
      service_rule = new name:name
      match = /^regex:(.*)/.match(url)
      if match
        service_rule.url = match[1]
        service_rule.regex = true
      else
        service_rule.url = clean_service_url(url)
      end

      service_rule.save!

      if service_rule.unsafe_regex?
        CASinoCore.config.logger.warn 'Potentially unsafe regex! Use ^ to ' \
                                      'match the beginning of the URL. ' \
                                      'Example: ^https://'
      end
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

  def save!(*args)
    return super if defined?(super)

    raise NotImplementedError, 'The defined ORM-compatibility layer has ' \
                                'not defined a :save! method'
  end

  def allows?(service_url)
    if self.regex.blank?
      self.url == service_url
    else
      Regexp.new(url, true) =~ service_url
    end
  end

  def unsafe_regex?
    return false unless regex

    url[0] != '^'
  end
end
