# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/view/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-view'
  spec.version       = Lotus::View::VERSION
  spec.authors       = ['Luca Guidi']
  spec.email         = ['me@lucaguidi.com']
  spec.description   = %q{View layer for Lotus}
  spec.summary       = %q{View layer for Lotus, with a separation between views and templates}
  spec.homepage      = 'http://lotusrb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md lotus-view.gemspec`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'tilt',        '~> 2.0', '>= 2.0.1'
  spec.add_runtime_dependency 'lotus-utils', '~> 0.2'

  spec.add_development_dependency 'bundler',  '~> 1.5'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake',     '~> 10'
end
