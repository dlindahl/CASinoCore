module CASinoCore
  module Helper
    module Authentication

      def validate_login_credentials(username, password)
        authentication_result = nil

        authenticators.each do |authenticator_name, authenticator|
          begin
            data = authenticator.validate(username, password)
          rescue CASinoCore::Authenticator::AuthenticatorError => e
            logger.error "Authenticator '#{authenticator_name}' (#{authenticator.class}) raised an error: #{e}"
          end
          if data
            authentication_result = { authenticator: authenticator_name, user_data: data }
            logger.info("Credentials for username '#{data[:username]}' successfully validated using authenticator '#{authenticator_name}' (#{authenticator.class})")
            break
          end
        end
        authentication_result
      end

      def authenticators
        @authenticators ||= begin
          CASinoCore.config.authenticators.each do |name, auth|
            next if auth.is_a? CASinoCore::Authenticator

            authenticator = if auth[:class]
              auth[:class].constantize
            else
              load_authenticator(auth[:authenticator])
            end

            CASinoCore.config.authenticators[name] = authenticator.new(auth[:options])
          end
        end
      end

      private
      def load_authenticator(name)
        gemname, classname = parse_name(name)

        begin
          require gemname
          CASinoCore::Authenticator.const_get(classname)
        rescue LoadError => error
          msg = "Failed to load authenticator '#{name}'. Maybe you have to " \
                "include \"gem '#{gemname}'\" in your Gemfile?\n" \
                "  Error: #{error.message}\n"

          raise LoadError, msg
        rescue NameError => error
          msg = "Failed to load authenticator '#{name}'. The authenticator class " \
                "must be defined in the CASinoCore::Authenticator namespace.\n" \
                "  Error: #{error.message}\n"

          raise NameError, msg
        end
      end

      def parse_name(name)
        [ "casino_core-authenticator-#{name.underscore}", name.camelize ]
      end

    end
  end
end
