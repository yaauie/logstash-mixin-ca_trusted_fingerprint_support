# CA Trusted Fingerprint Support Mixin

[![Build Status](https://travis-ci.com/logstash-plugins/logstash-mixin-ca_trusted_fingerprint_support.svg?branch=main)](https://travis-ci.com/logstash-plugins/logstash-mixin-ca_trusted_fingerprint_support)

This gem provides tooling for adding a `ca_trusted_fingerprint` option to Logstash Plugins that maps to an Apache SSL `TrustStrategy` for use by Manticore or Apache HTTP client.

## Usage

1. Add version `~>1.0` of this gem as a runtime dependency of your Logstash plugin's `gemspec`:

    ~~~ ruby
    Gem::Specification.new do |s|
      # ...

      s.add_runtime_dependency 'logstash-mixin-ca_trusted_fingerprint_support', '~>1.0'
    end
    ~~~

2. In your plugin code, require this library and include it into your plugin class
   that already inherits `LogStash::Plugin`:

    ~~~ ruby
    require 'logstash/plugin_mixins/ca_trusted_fingerprint_support'

    class LogStash::Inputs::Foo < Logstash::Inputs::Base
      # config :ca_trusted_fingerprint, :validate => :sha_256_hex
      include LogStash::PluginMixins::CATrustedFingerprintSupport

      # ...
    end
    ~~~

3. Use the provided `trust_strategy_for_ca_trusted_fingerprint` method to acquire an 
   appropriate trust strategy for the given `ca_trusted_fingerprint`(s), or `nil` if
   no `ca_trusted_fingerprint`s were provided. 

    ~~~ ruby
      def register
        # ...
        ssl_options.merge(:trust_strategy, trust_strategy_for_ca_trusted_fingerprint)
        @client = Manticore::Client.new(ssl: ssl_options)
      end
    ~~~

## Development

This gem:
 - *MUST* remain API-stable at 1.x
 - *MUST NOT* introduce additional runtime dependencies
