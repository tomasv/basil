module SillyBot
  def self.configure
    yield configuration
  end

  def self.configuration
    SillyBot::Configuration
  end

  class Configuration
    class << self
      def self.option name, default
        attr_accessor name
        default = -> { default } unless default.respond_to? :call
        define_method(name) {
          opt = instance_variable_get("@#{name}")
          if not opt
            default_value = default.call
            instance_variable_set("@#{name}", default_value)
            default_value
          else
            opt
          end
        }
      end

      option :storage, -> { Basil::Storage }
      option :logger, -> { Logger.new(STDOUT) }
    end
  end
end
