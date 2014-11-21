require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
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
require 'lotus/view'

Lotus::View.configure do
  root Pathname.new __dir__ + '/fixtures/templates'
end

require 'fixtures'

Lotus::Utils::LoadPaths.class_eval do
  def include?(object)
    @paths.include?(object)
  end

  def ==(other)
    other.kind_of?(Lotus::Utils::LoadPaths) &&
      other.paths == self.paths
  end

  protected
  attr_reader :paths
end

Lotus::View::Configuration.class_eval do
  def ==(other)
    other.kind_of?(Lotus::View::Configuration) &&
      self.namespace  == other.namespace  &&
      self.root       == other.root       &&
      self.layout     == other.layout     &&
      self.load_paths == other.load_paths
  end
end
