require 'rubygems'
require 'bundler/setup'
require 'tilt/erb'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'test'
    add_filter   'test'
  end
end

require 'minitest/autorun'
$:.unshift 'lib'
require 'hanami/view'

configuration = Hanami::View::Configuration.new do
  root Pathname.new __dir__ + '/fixtures/templates'
end

Hanami::View.configuration = configuration

module Unloadable
  def unload!
    self.configuration = configuration.duplicate
    configuration.unload!
  end
end

require 'fixtures'
Hanami::View.load!

Hanami::View.class_eval do
  extend Unloadable
end

Hanami::Utils::LoadPaths.class_eval do
  def include?(object)
    @paths.include?(object)
  end
end

Hanami::View::Configuration.class_eval do
  def ==(other)
    other.kind_of?(Hanami::View::Configuration) &&
      self.namespace  == other.namespace  &&
      self.root       == other.root       &&
      self.layout     == other.layout     &&
      self.load_paths == other.load_paths
  end
end
