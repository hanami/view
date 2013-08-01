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
  spec.summary       = %q{View layer for Lotus}
  spec.homepage      = 'http://lotusrb.org/lotus-view'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'tilt'

  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake'
end
