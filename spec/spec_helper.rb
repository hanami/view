if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

require 'hanami/utils'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end

TEMPLATE_ROOT_DIRECTORY = Pathname.new __dir__ + '/support/fixtures/templates'

$LOAD_PATH.unshift 'lib'
require 'hanami/view'

require_relative 'unloadable.rb'
require_relative 'helpers.rb'

Hanami::View.configure do
  root TEMPLATE_ROOT_DIRECTORY
end

Hanami::Utils.require!('spec/support')

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
