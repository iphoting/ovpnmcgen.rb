# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ovpnmcgen/version'

Gem::Specification.new do |spec|
  spec.name          = "ovpnmcgen.rb"
  spec.version       = Ovpnmcgen::VERSION
  #spec.version       = "#{spec.version}-pre-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  spec.authors       = ["Ronald Ip"]
  spec.email         = ["myself@iphoting.com"]
  spec.summary       = Ovpnmcgen::SUMMARY
  spec.description   = "Generates iOS configuration profiles (.mobileconfig) that configures OpenVPN for use with VPN-on-Demand that are not accessible through the Apple Configurator or the iPhone Configuration Utility."
  spec.homepage      = "https://github.com/iphoting/ovpnmcgen.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir = 'bin'
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "aruba", "~> 1.0", ">= 0.5.4"
  spec.add_development_dependency "pre-commit"
  spec.add_runtime_dependency     "plist", "~> 3.5", ">= 3.5.0"
  spec.add_runtime_dependency     "commander", "~> 4.4", ">= 4.4.7"
  spec.add_runtime_dependency     "app_configuration", "~> 0.0", ">= 0.0.2"
end
