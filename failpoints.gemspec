# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'failpoints/version'

Gem::Specification.new do |spec|
  spec.name          = "failpoints"
  spec.version       = Failpoints::VERSION
  spec.authors       = ["Daniel Starling"]
  spec.email         = ["ds@blinkbeam.com"]
  spec.summary       = %q{Provides a way to force failure of deterministic algorithms to test recoverability}
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "GPL v3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.required_ruby_version = '>= 1.9.2'
end

