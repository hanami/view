# frozen_string_literal: true

require_relative "support/coverage"

begin
  require "pry-byebug"
rescue LoadError; end
SPEC_ROOT = Pathname(__FILE__).dirname
FIXTURES_PATH = SPEC_ROOT.join("fixtures")

require "slim"
require "hanami/view"

module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed

  config.after do
    Test.remove_constants
  end

  config.after do
    [
      Hanami::View,
      Hanami::View::PartBuilder,
      Hanami::View::Path,
      Hanami::View::Renderer,
      Hanami::View::ScopeBuilder,
      Hanami::View::Tilt
    ].each do |klass|
      klass.cache.clear
    end
  end
end

RSpec::Matchers.define :part_including do |data|
  match { |actual|
    data.all? { |(key, val)|
      actual._data[key] == val
    }
  }
end
