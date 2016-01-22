require 'hanami/utils/class_attribute'
require 'hanami/view/rendering/layout_registry'
require 'hanami/view/rendering/layout_scope'
require 'hanami/view/rendering/null_layout'

module Hanami
  # Layout
  #
  # @since 0.1.0
  #
  # @see Hanami::Layout::ClassMethods
  module Layout
    # Register a layout
    #
    # @api private
    # @since 0.1.0
    #
    # @example
    #   require 'hanami/view'
    #
    #   class ApplicationLayout
    #     include Hanami::Layout
    #   end
    def self.included(base)
      conf = Hanami::View::Configuration.for(base)
      conf.add_layout(base)

      base.class_eval do
        extend Hanami::View::Dsl.dup
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
      # @see Hanami::Layout::ClassMethods#suffix
      # @see Hanami::Layout::ClassMethods#template
      SUFFIX = '_layout'.freeze

      # A registry that holds all the registered layouts.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View::Rendering::LayoutRegistry
      def registry
        @registry ||= View::Rendering::LayoutRegistry.new(self)
      end

      # Template name
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::Layout::ClassMethods#SUFFIX
      # @see Hanami::Layout::ClassMethods#suffix
      #
      # @example
      #   # Given a template 'templates/application.html.erb'
      #
      #   class ApplicationLayout
      #     include Hanami::Layout
      #   end
      #
      # ApplicationLayout.template # => 'application'
      def template
        super.sub(suffix, '')
      end

      # Template name suffix
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::Layout::ClassMethods#SUFFIX
      # @see Hanami::Layout::ClassMethods#template
      def suffix
        SUFFIX
      end

      protected
      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View.load!
      def load!
        registry.freeze
        configuration.freeze
      end
    end

    # Initialize a layout
    #
    # @param scope [Hanami::View::Rendering::Scope] view rendering scope
    # @param rendered [String] the output of the view rendering process
    #
    # @api private
    # @since 0.1.0
    #
    # @see Hanami::View::Rendering#render
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
    # @see Hanami::View::Rendering#render
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
