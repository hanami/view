# frozen_string_literal: true

require "pathname"
TEMPLATE_ROOT_DIRECTORY = Pathname.new(__dir__).join("support", "fixtures", "templates")

$LOAD_PATH.unshift "lib"
require "hanami/utils"
require "hanami/devtools/unit"
require "hanami/view"

require_relative "unloadable.rb"
require_relative "helpers.rb"

Hanami::View.configure do
  root TEMPLATE_ROOT_DIRECTORY
end

Hanami::Utils.require!("spec/support")

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
    other.is_a?(Hanami::View::Configuration) &&
      namespace  == other.namespace  &&
      root       == other.root       &&
      layout     == other.layout     &&
      load_paths == other.load_paths
  end
end
