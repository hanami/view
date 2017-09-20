# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dry/view/version'

Gem::Specification.new do |spec|
  spec.name          = "dry-view"
  spec.version       = Dry::View::VERSION
  spec.authors       = ["Piotr Solnica", "Tim Riley"]
  spec.email         = ["piotr.solnica@gmail.com", "tim@icelab.com.au"]
  spec.summary       = "Functional view rendering system"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/dry-rb/dry-view"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency "tilt", "~> 2.0"
  spec.add_runtime_dependency "dry-core", "~> 0.2"
  spec.add_runtime_dependency "dry-configurable", "~> 0.1"
  spec.add_runtime_dependency "dry-equalizer", "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end
