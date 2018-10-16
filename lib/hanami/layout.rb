require 'hanami/utils/class_attribute'
require 'hanami/view/rendering/layout_registry'
require 'hanami/view/rendering/layout_scope'
require 'hanami/view/rendering/null_layout'
require 'hanami/view/rendering/null_view'

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
        load_registry!
        configuration.freeze
      end

      private

      # @api private
      def load_registry!
        @registry = nil
        registry.freeze
      end
    end

    # Initialize a layout
    #
    # @param scope [Hanami::View::Rendering::Scope,::Hash] view rendering scope.
    #   Optionally a scope can be expressed as a Ruby `::Hash`, but it MUST contain
    #   the `:format` key, to specify which template to render.
    # @option scope [Symbol] :format the format to render (e.g. `:html`, `:xml`, `:json`)
    #   This is mandatory only if a `:Hash` is passed as `scope`.
    #
    # @param rendered [String] the output of the view rendering process
    #
    # @api private
    # @since 0.1.0
    #
    # @see Hanami::View::Rendering#render
    def initialize(scope, rendered)
      # NOTE: This complex data transformation is due to a combination of a bug and the intent of maintaing backward compat (SemVer).
      # See https://github.com/hanami/view/pull/156
      s, r = *case scope
              when ::Hash
                [Hanami::View::Rendering::Scope.new(Hanami::View::Rendering::NullView, scope), rendered]
              when Hanami::View::Template
                [Hanami::View::Rendering::Scope.new(Hanami::View::Rendering::NullView, rendered.merge(format: scope.format)), ""]
              else
                [scope, rendered]
              end

      @scope = View::Rendering::LayoutScope.new(self, s)
      @rendered = r
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

    # It tries to invoke a method for the view or a local for the given key.
    # If the lookup fails, it returns a null object.
    #
    # @return [Object,Hanami::View::Rendering::NullLocal] the returning value
    #
    # @since 1.1.0
    #
    # @example Safe method navigation
    #   class ApplicationLayout
    #     include Hanami::Layout
    #
    #     def render_flash
    #       return if local(:flash).nil?
    #
    #       # ...
    #     end
    #   end
    def local(key)
      @scope.local(key)
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
