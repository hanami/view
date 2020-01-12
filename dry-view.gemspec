# frozen_string_literal: true
# this file is managed by dry-rb/devtools project

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dry/view/version'

Gem::Specification.new do |spec|
  spec.name          = 'dry-view'
  spec.authors       = ["Tim Riley", "Piotr Solnica"]
  spec.email         = ["tim@icelab.com.au", "piotr.solnica@gmail.com"]
  spec.license       = 'MIT'
  spec.version       = Dry::View::VERSION.dup

  spec.summary       = "A complete, standalone view rendering system that gives you everything you need to write well-factored view code"
  spec.description   = spec.summary
  spec.homepage      = 'https://dry-rb.org/gems/dry-view'
  spec.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'dry-view.gemspec', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['changelog_uri']     = 'https://github.com/dry-rb/dry-view/blob/master/CHANGELOG.md'
  spec.metadata['source_code_uri']   = 'https://github.com/dry-rb/dry-view'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/dry-rb/dry-view/issues'

  spec.required_ruby_version = '>= 2.4.0'

  # to update dependencies edit project.yml
  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0"
  spec.add_runtime_dependency "dry-configurable", "~> 0.1"
  spec.add_runtime_dependency "dry-core", "~> 0.2"
  spec.add_runtime_dependency "dry-equalizer", "~> 0.2"
  spec.add_runtime_dependency "dry-inflector", "~> 0.1"
  spec.add_runtime_dependency "tilt", "~> 2.0", ">= 2.0.6"
  spec.add_development_dependency "bundler"  spec.add_development_dependency "rake"  spec.add_development_dependency "rspec"
end
