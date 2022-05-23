# encoding: utf-8

require 'logstash/namespace'
require 'logstash/plugin'

module LogStash
  module PluginMixins
    ##
    # This `CATrustedFingerprintSupport` can be included in any `LogStash::Plugin`,
    # and will ensure that the plugin provides a `ca_trusted_fingerprint` option that
    # accepts a list of string values.
    #
    # When Logstash provides its own CATrustedFingerprint support, it will be used
    # in place of the stub provided by this support adapter.
    #
    # When run on a Logstash that does _not_ provide its own CATrustedFingerprint
    # support, using the `ca_trusted_fingerprint` option is considered a configuration
    # error and will prevent the plugin from being initialized.
    module CATrustedFingerprintSupport

      ##
      # @api internal (use: `LogStash::Plugin::include`)
      # @param base [Class]: a class that inherits `LogStash::Plugin`, typically one
      #                      descending from one of the four plugin base classes
      #                      (e.g., `LogStash::Inputs::Base`)
      # @return [void]
      def self.included(base)
        fail(ArgumentError, "`#{base}` must inherit LogStash::Plugin") unless base < LogStash::Plugin

        base.include(defined?(BuiltInAdapter) ? BuiltInAdapter : LegacyAdapter)
      end

      module LegacyAdapter
        def included(base)
          base.config(:ca_trusted_fingerprint, :validate => :string, :list => true)
        end

        def config_init(params)
          if params.include?("ca_trusted_fingerprint")
            raise LogStash::ConfigurationError, I18n.t(
              "logstash.runner.configuration.invalid_plugin_register",
              :plugin => self.class.config_name,
              :type => self.class.plugin_type,
              :error => "The `ca_trusted_fingerprint` option requires Logstash 8.3+; please remove the setting or upgrade Logstash."
            )
          end
          super
        end

        def trust_strategy_for_ca_trusted_fingerprint
          nil # API compatibility with core
        end
      end

      if defined?(::LogStash::Plugins::CATrustedFingerprintSupport)
        module BuiltInAdapter
          def self.included(base)
            base.include(::LogStash::Plugins::CATrustedFingerprintSupport)
          end
        end
      end
    end
  end
end
