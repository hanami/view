require 'lotus/utils/class_attribute'
require 'lotus/view/rendering/layout_registry'
require 'lotus/view/rendering/layout_scope'
require 'lotus/view/rendering/null_layout'

module Lotus
  # Layout
  #
  # @since 0.1.0
  #
  # @see Lotus::Layout::ClassMethods
  module Layout
    # Register a layout
    #
    # @api private
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/view'
    #
    #   class ApplicationLayout
    #     include Lotus::Layout
    #   end
    def self.included(base)
      conf = Lotus::View::Configuration.for(base)
      conf.add_layout(base)

      base.class_eval do
        extend Lotus::View::Dsl.dup
        extend ClassMethods

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
      end

      conf.copy!(base)
    end

    # Class level API
    #
    # @since 0.1.0
    module ClassMethods
      # Template name suffix
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Layout::ClassMethods#suffix
      # @see Lotus::Layout::ClassMethods#template
      SUFFIX = '_layout'.freeze

      # A registry that holds all the registered layouts.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View::Rendering::LayoutRegistry
      def registry
        @registry ||= View::Rendering::LayoutRegistry.new(self)
      end

      # Template name
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Layout::ClassMethods#SUFFIX
      # @see Lotus::Layout::ClassMethods#suffix
      #
      # @example
      #   # Given a template 'templates/application.html.erb'
      #
      #   class ApplicationLayout
      #     include Lotus::Layout
      #   end
      #
      # ApplicationLayout.template # => 'application'
      def template
        super.gsub(suffix, '')
      end

      # Template name suffix
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Layout::ClassMethods#SUFFIX
      # @see Lotus::Layout::ClassMethods#template
      def suffix
        SUFFIX
      end

      protected
      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View.load!
      def load!
        registry.freeze
        configuration.freeze
      end
    end

    # Initialize a layout
    #
    # @param scope [Lotus::View::Rendering::Scope] view rendering scope
    # @param rendered [String] the output of the view rendering process
    #
    # @api private
    # @since 0.1.0
    #
    # @see Lotus::View::Rendering#render
    def initialize(scope, rendered)
      @scope, @rendered = View::Rendering::LayoutScope.new(self, scope), rendered
    end

    # Render the layout
    #
    # @return [String] the output of the rendering process
    #
    # @api private
    # @since 0.1.0
    #
    # @see Lotus::View::Rendering#render
    def render
      template.render(@scope, &Proc.new{@rendered})
    end

    protected
    # The template for the current format
    #
    # @api private
    # @since 0.1.0
    def template
      self.class.registry.resolve({format: @scope.format})
    end
  end
end
