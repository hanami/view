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

      base.class_eval do
        extend Inheritable.dup
        extend Dsl.dup
        extend Rendering.dup

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf
      end

      views.add(base)
    end

    include Utils::ClassAttribute

    class_attribute :configuration
    self.configuration = Configuration.new

    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end

    # A set of registered views.
    #
    # @return [Set] all the registered views.
    #
    # @api private
    # @since 0.1.0
    def self.views
      @views ||= Set.new
    end

    # A set of registered layouts.
    #
    # @return [Set] all the registered layout.
    #
    # @api private
    # @since 0.1.0
    def self.layouts
      @layouts ||= Set.new
    end

    #FIXME extract a Loader class
    def self.load!
      views.freeze

      views.each do |view|
        view.send(:load!)
      end

      layouts.each do |layout|
        layout.send(:load!)
      end
    end

    def self.unload!
      instance_variable_set(:@views, Set.new)
      instance_variable_set(:@layouts, Set.new)
    end
  end
end
