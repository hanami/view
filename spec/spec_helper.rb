if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

begin
  require 'byebug'
rescue LoadError; end

SPEC_ROOT = Pathname(__FILE__).dirname

require 'dry-view'
require 'slim'
require 'erb'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed
end
