Gem::Specification.new do |s|
  s.name          = 'logstash-mixin-ca_trusted_fingerprint_support'
  s.version       = "1.0.0"
  s.licenses      = %w(Apache-2.0)
  s.summary       = "Support for bypassing the TrustManager when presented with a certificate chain containing a matching fingerprint. Currently supports Apache HTTP, including Manticore"
  s.description   = "This gem is meant to be a dependency of any Logstash plugin that wishes to use ca_trusted_fingerprint while maintaining backward-compatibility with earlier Logstash releases. When used on older Logstash versions, the provided `ca_trusted_fingerprint` option cannot be used."
  s.authors       = %w(Elastic)
  s.email         = 'info@elastic.co'
  s.homepage      = 'https://github.com/logstash-plugins/logstash-mixin-ca_trusted_fingerprint_support'
  s.require_paths = %w(lib vendor/jar-dependencies)

  s.files = %w(ext lib spec vendor).flat_map{|dir| Dir.glob("#{dir}/**/*")}+Dir.glob(["*.md","LICENSE"])

  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.platform = RUBY_PLATFORM

  s.add_runtime_dependency 'logstash-core', '>= 7.0.0'

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rspec-its', '~>1.3'
  s.add_development_dependency 'logstash-codec-plain', '>= 3.1.0' # TODO: really?
end
