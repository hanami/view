require 'set'
require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/view/version'
require 'lotus/view/configuration'
require 'lotus/view/inheritable'
require 'lotus/view/rendering'
require 'lotus/view/dsl'
require 'lotus/layout'
require 'lotus/presenter'

module Lotus
  # View
  #
  # @since 0.1.0
  module View
    # Missing template error
    #
    # This is raised at the runtime when Lotus::View cannot find a template for
    # the requested format.
    #
    # We can't raise this error during the loading phase, because at that time
    # we don't know if a view implements its own rendering policy.
    # A view is allowed to override `#render`, and this scenario can make the
    # presence of a template useless. One typical example is the usage of a
    # serializer that returns the output string, without rendering a template.
    #
    # @since 0.1.0
    class MissingTemplateError < ::StandardError
      def initialize(template, format)
        super("Can't find template '#{ template }' for '#{ format }' format.")
      end
    end

    # Missing format error
    #
    # This is raised at the runtime when rendering context lacks of the :format
    # key.
    #
    # @since 0.1.0
    #
    # @see Lotus::View::Rendering#render
    class MissingFormatError < ::StandardError
    end

    # Register a view
    #
    # @api private
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/view'
    #
    #   class IndexView
    #     include Lotus::View
    #   end
    def self.included(base)
      conf = self.configuration
      conf.add_view(base)

      base.class_eval do
        extend Inheritable.dup
        extend Dsl.dup
        extend Rendering.dup

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
      end
    end

    include Utils::ClassAttribute

    # @since 0.2.0
    class_attribute :configuration
    self.configuration = Configuration.new

    # @since 0.2.0
    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end

    # @since 0.2.0
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    # @since 0.2.0
    def self.duplicate(mod, views = 'Views', &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{
          module #{ views }; end
          Layout = Lotus::Layout.dup
        }

        duplicated.configure do
          namespace "#{ mod }::#{ views }"
        end

        duplicated.configure(&blk) if block_given?
      end
    end

    def self.load!
      configuration.load!
    end

    def self.unload!
      configuration.unload!
    end
  end
end
