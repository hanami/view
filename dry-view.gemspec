# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dry/view/version'

Gem::Specification.new do |spec|
  spec.name          = 'dry-view'
  spec.version       = Dry::View::VERSION
  spec.authors       = ['Tim Riley', 'Piotr Solnica']
  spec.email         = ['tim@icelab.com.au', 'piotr.solnica@gmail.com']
  spec.summary       = 'A complete, standalone view rendering system that gives you everything you need to write well-factored view code'
  spec.description   = spec.summary
  spec.homepage      = 'https://dry-rb.org/gems/dry-view'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(benchmarks|examples|spec)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency 'tilt', '~> 2.0', '>= 2.0.6'
  spec.add_runtime_dependency 'dry-core', '~> 0.2'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.1'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-inflector', '~> 0.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
end
