require 'lotus/view/rendering/registry'
require 'lotus/view/rendering/scope'

module Lotus
  module View
    # Rendering methods
    #
    # @since 0.1.0
    #
    # @see Lotus::View::Rendering::InstanceMethods
    module Rendering
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        # Initialize a view
        #
        # @param template [Lotus::View::Template] the template to render
        # @param locals [Hash] a set of objects available during the rendering
        #   process.
        #
        # @since 0.1.0
        #
        # @see Lotus::View::Template
        #
        # @example
        #   require 'lotus/view'
        #
        #   class IndexView
        #     include Lotus::View
        #   end
        #
        #   template = Lotus::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        def initialize(template, locals)
          @template = template
          @locals   = locals
          @scope    = Scope.new(self, @locals)
        end

        # Render the template by bounding the local scope.
        # If it uses a layout, it renders the template first and then the
        # control passes to the layout.
        #
        # Override this method for custom rendering policies.
        # For instance, when a serializer is used and there isn't the need of
        # a template.
        #
        # @return [String] the output of the rendering process
        #
        # @raise [Lotus::View::MissingTemplateError] if the template is nil
        #
        # @since 0.1.0
        #
        # @see Lotus::View::Layout
        #
        # @example with template
        #   require 'lotus/view'
        #
        #   class IndexView
        #     include Lotus::View
        #   end
        #
        #   template = Lotus::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        #
        #   view.render # => <h1>Introducing Lotus::view</h1> ...
        #
        # @example with template and layout
        #   require 'lotus/view'
        #
        #   class ApplicationLayout
        #     include Lotus::View::Layout
        #   end
        #
        #   class IndexView
        #     include Lotus::View
        #     layout :application
        #   end
        #
        #   template = Lotus::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        #
        #   view.render # => <html> ... <h1>Introducing Lotus::view</h1> ...
        #
        # @example with custom rendering
        #   require 'lotus/view'
        #
        #   class IndexView
        #     include Lotus::View
        #
        #     def render
        #       ArticleSerializer.new(article).render
        #     end
        #   end
        #
        #   view = IndexView.new(nil, {article: article})
        #
        #   view.render # => {title: ...}
        def render
          layout.render
        end

        protected
        # The output of the template rendering process.
        #
        # @return [String] the rendering output
        #
        # @raise [Lotus::View::MissingTemplateError] if the template is nil
        #
        # @api private
        # @since 0.1.0
        def rendered
          template.render @scope
        end

        # The layout.
        #
        # @return [Class, Lotus::View::Rendering::NullLayout]
        #
        # @see Lotus::View::Layout
        # @see Lotus::View.layout
        # @see Lotus::View::Dsl#layout
        #
        # @api private
        # @since 0.1.0
        def layout
          @layout ||= self.class.layout.new(@scope, rendered)
        end

        # The template.
        #
        # @return [Lotus::View::Template] the template
        #
        # @raise [Lotus::View::MissingTemplateError] if the template is nil
        #
        # @api private
        # @since 0.1.0
        def template
          @template or raise MissingTemplateError.new(self.class.template, @scope.format)
        end

        # A set of objects available during the rendering process.
        #
        # @return [Hash]
        #
        # @see Lotus::View#initialize
        #
        # @api private
        # @since 0.1.0
        def locals
          @locals
        end

        # Delegates missing methods to the scope.
        #
        # @see Lotus::View::Rendering::Scope
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
        #
        #   template = Lotus::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        #
        #   view.article # => #<Article:0x007fb0bbd3b6e8>
        def method_missing(m)
          @scope.__send__ m
        end
      end

      # Render the given context and locals with the appropriate template.
      # If there are registered subclasses, it choose the right class, according
      #   to the requested format.
      #
      # @param context [Hash] the context for the rendering process
      # @option context [Symbol] :format the requested format
      #
      # @return [String] the output of the rendering process
      #
      # @raise [Lotus::View::MissingTemplateError] if it can't find a template
      #   for the given context
      #
      # @raise [Lotus::View::MissingFormatError] if the given context doesn't
      #   have the :format key
      #
      # @since 0.1.0
      #
      # @see Lotus::View#initialize
      # @see Lotus::View#render
      #
      # @example
      #   require 'lotus/view'
      #
      #   article = OpenStruct.new(title: 'Hello')
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #
      #       def title
      #         @title ||= article.title.upcase
      #       end
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #
      #       def title
      #         super.downcase
      #       end
      #     end
      #   end
      #
      #   Lotus::View.root = '/path/to/templates'
      #   Lotus::View.load!
      #
      #   Articles::Show.render(format: :html,  article: article)
      #     # => renders `articles/show.html.erb`
      #
      #   Articles::Show.render(format: :json, article: article)
      #     # => renders `articles/show.json.erb`
      #
      #   Articles::Show.render(format: :xml, article: article)
      #     # => raises Lotus::View::MissingTemplateError
      def render(context)
        registry.resolve(context).render
      end

      protected

      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View.load!
      def load!
        super
        registry.freeze
      end

      private

      # The registry that holds all the registered subclasses.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View::Rendering::Registry
      def registry
        @@registry ||= Registry.new(self)
      end
    end
  end
end
