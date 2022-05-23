# encoding: utf-8

require 'rspec/its'

require "logstash-core"

require 'logstash/inputs/base'
require 'logstash/filters/base'
require 'logstash/codecs/base'
require 'logstash/outputs/base'

require 'logstash/codecs/plain' # to init base plugin with default codec

require "logstash/plugin_mixins/ca_trusted_fingerprint_support"

describe LogStash::PluginMixins::CATrustedFingerprintSupport do
  let(:ca_trusted_fingerprint_support) { described_class }

  context 'included into a class' do
    context 'that does not inherit from `LogStash::Plugin`' do
      let(:plugin_class) { Class.new }
      it 'fails with an ArgumentError' do
        expect do
          plugin_class.send(:include, ca_trusted_fingerprint_support)
        end.to raise_error(ArgumentError, /LogStash::Plugin/)
      end
    end

    [
      LogStash::Inputs::Base,
      LogStash::Filters::Base,
      LogStash::Codecs::Base,
      LogStash::Outputs::Base
    ].each do |base_class|
      context "that inherits from `#{base_class}`" do
        native_support_for_plugin_factory = Gem::Version.create(LOGSTASH_VERSION) >= Gem::Version.create("8.3.0")

        let(:plugin_base_class) { base_class }

        subject(:plugin_class) do
          Class.new(plugin_base_class) do
            config_name 'test'
          end
        end

        context 'the result' do
          before(:each) do
            plugin_class.send(:include, ca_trusted_fingerprint_support)
          end

          context 'class composition' do
            if native_support_for_plugin_factory
              its(:ancestors) { is_expected.to_not include(ca_trusted_fingerprint_support::LegacyAdapter) }
              its(:ancestors) { is_expected.to include(::LogStash::Plugins::CATrustedFingerprintSupport) }
            else
              its(:ancestors) { is_expected.to include(ca_trusted_fingerprint_support::LegacyAdapter)}
            end
          end

          context '#initialize' do

            let(:config) { Hash.new }
            let(:ca_sha) { "1bad1dea"*8 }

            context 'instantiating a plugin without `ca_trusted_fingerprint`s' do
              subject(:instance) { plugin_class.new config }
              it 'satisfies the interface' do
                expect(instance).to be_a_kind_of plugin_class
                expect(instance).to respond_to(:trust_strategy_for_ca_trusted_fingerprint)
                expect(instance.trust_strategy_for_ca_trusted_fingerprint).to be_nil
              end
            end

            unless native_support_for_plugin_factory

              context 'instantiating a plugin with one `ca_trusted_fingerprint`' do
                let(:config) { super().merge("ca_trusted_fingerprint" => ca_sha) }
                it 'is a configuration error' do
                  expect { plugin_class.new config }.to raise_exception(LogStash::ConfigurationError, a_string_including("`ca_trusted_fingerprint` option requires Logstash 8.3"))
                end
              end

              context 'instantiating a plugin with an array of `ca_trusted_fingerprint`s' do
                let(:config) { super().merge("ca_trusted_fingerprint" => [ca_sha, ca_sha.reverse]) }
                it 'is a configuration error' do
                  expect { plugin_class.new config }.to raise_exception(LogStash::ConfigurationError, a_string_including("`ca_trusted_fingerprint` option requires Logstash 8.3"))
                end
              end
            end
          end
        end
      end
    end
  end
end
