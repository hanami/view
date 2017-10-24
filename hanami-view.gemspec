# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hanami/view/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanami-view'
  spec.version       = Hanami::View::VERSION
  spec.authors       = ['Luca Guidi']
  spec.email         = ['me@lucaguidi.com']
  spec.description   = %q{View layer for Hanami}
  spec.summary       = %q{View layer for Hanami, with a separation between views and templates}
  spec.homepage      = 'http://hanamirb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-view.gemspec`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency 'tilt',         '~> 2.0', '>= 2.0.1'
  spec.add_runtime_dependency 'hanami-utils', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rspec',   '~> 3.7'
  spec.add_development_dependency 'rake',    '~> 12'
end
