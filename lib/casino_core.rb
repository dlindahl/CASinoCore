require 'active_support/inflector'
require 'active_support/configurable'
require 'active_support/string_inquirer'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_dup'
require 'casino_core/errors'

module CASinoCore
  include ActiveSupport::Configurable

  autoload :Authenticator, 'casino_core/authenticator.rb'
  autoload :Concerns, 'casino_core/concerns.rb'
  autoload :Helper, 'casino_core/helper.rb'
  autoload :Model, 'casino_core/model.rb'
  autoload :Processor, 'casino_core/processor.rb'

  require 'casino_core/railtie' if defined?(Rails)

  defaults = {
    application_root: '.',
    authenticators: HashWithIndifferentAccess.new,
    logger: defined?(::Logger) ? ::Logger.new(STDOUT) : nil,
    frontend: {},
    implementors: HashWithIndifferentAccess.new(
      login_ticket: nil
    ),
    login_ticket: {
      lifetime: 600
    },
    ticket_granting_ticket: {
      lifetime: 86400,
      lifetime_long_term: 864000
    },
    service_ticket: {
      lifetime_unconsumed: 300,
      lifetime_consumed: 86400,
      single_sign_out_notification: {
        timeout: 5
      }
    },
    proxy_ticket: {
      lifetime_unconsumed: 300,
      lifetime_consumed: 86400
    },
    two_factor_authenticator: {
      timeout: 180,
      lifetime_inactive: 300,
      drift: 30
    }
  }

  self.config.merge! defaults.deep_dup

  mattr_reader :env
  def self.env=(environment)
    @@env = ActiveSupport::StringInquirer.new(environment)
  end
  self.env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'

  def self.setup(environment = nil, options = {})
    self.env = environment if environment
    config.application_root = options.fetch(:application_root, config.application_root)

    apply_yaml_config load_file('config/cas.yml')
  end

  def self.apply_yaml_config(yaml)
    cfg = (YAML.load(ERB.new(yaml).result)||{}).fetch(env, {})
    cfg.each do |k,v|
      value = if v.is_a? Hash
        self.config.fetch(k.to_sym,{}).merge(v.symbolize_keys)
      else
        v
      end
      self.config.send("#{k}=", value)
    end
  end

  def self.implementor(name)
    impl = config.implementors[name.to_sym]
    impl = impl.constantize if impl.is_a? String
    impl or raise CASinoCore::MissingImplementorError.new(name, :missing)
  rescue NameError => e
    raise unless e.message =~ %r{uninitialized constant}
    raise CASinoCore::MissingImplementorError.new(name, :uninitialized, e)
  end

  private
  def self.load_file(filename)
    fullpath = File.join(self.config.application_root, filename)
    IO.read(fullpath) rescue ''
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'CAS'
  inflect.acronym 'CASino'
end
