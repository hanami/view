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
Lotus::View.load!

Lotus::View::Configuration.class_eval do
  def ==(other)
    other.kind_of?(Lotus::View::Configuration) &&
      self.root == other.root
  end
end
