require 'addressable/uri'

module CASinoCore
  module Helper
    module Url

      RESERVED_CAS_PARAMETER_KEYS = %w{service ticket gateway renew}

      def clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        service_uri = Addressable::URI.parse dirty_service
        unless service_uri.query_values.nil?
          service_uri.query_values = service_uri.query_values(Array).select do |k,v|
            !RESERVED_CAS_PARAMETER_KEYS.include?(k)
          end
        end
        if service_uri.query_values.blank?
          service_uri.query_values = nil
        end

        service_uri.path = (service_uri.path || '').gsub(/\/+\z/, '')
        service_uri.path = '/' if service_uri.path.blank?

        clean_service = service_uri.to_s

        CASinoCore.config.logger.debug("Cleaned dirty service URL '#{dirty_service}' to '#{clean_service}'") if dirty_service != clean_service

        clean_service
      end

    end
  end
end