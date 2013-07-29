module CASinoCore
  Error = Class.new(StandardError)
  ServiceNotAllowedError = Class.new(Error)

  class MissingImplementorError < Error
    def initialize(name, type, err=nil)
      @name, @type, @err = name.to_s, type, err
      super(text)
    end

    def text
      case @type
      when :missing then missing_message
      when :uninitialized then uninitialized_message
      else @type
      end
    end

    def title
      @name.classify.titleize
    end

    def missing_message
      "Missing #{title} CASinoCore implementation.\n" \
      "You must specify an ORM-backed class to handle CASinoCore's #{title} " \
      "logic:\n\n" \
      "    class Your#{@name.classify}\n" \
      "      include CASinoCore::Concerns::#{@name.classify}\n" \
      "    end\n\n" \
      "Once you have done that, configure CASinoCore with that class:\n\n" \
      "    CASinoCore.config.implementors[:#{@name}] = YourClass\n\n" \
      "Please refer to the CASinoCore documentation for more information.\n\n"
    end

    def uninitialized_message
      "#{@err.class}: #{@err.message}\n" \
      "Could not find the constant that you have defined for the #{title} " \
      "CASinoCore implementation.\n" \
      "Ensure that the constant is either pre-loaded or is findable by your " \
      "application's auto-loader."
    end
  end
end