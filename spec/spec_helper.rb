if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

begin
  require 'byebug'
rescue LoadError; end

SPEC_ROOT = Pathname(__FILE__).dirname

require 'tilt/erubis'
require 'slim'
require 'dry-view'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed
end
