require 'hanami/view/rendering/registry'
require 'hanami/view/rendering/scope'
require 'hanami/view/rendering/subscope'
require 'hanami/view/rendering/null_local'

module Hanami
  module View
    # Rendering methods
    #
    # @since 0.1.0
    #
    # @see Hanami::View::Rendering::InstanceMethods
    module Rendering
      # @since 0.1.0
      # @api private
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        # Initialize a view
        #
        # @param template [Hanami::View::Template] the template to render
        # @param locals [Hash] a set of objects available during the rendering
        #   process.
        #
        # @since 0.1.0
        #
        # @see Hanami::View::Template
        #
        # @example
        #   require 'hanami/view'
        #
        #   class IndexView
        #     include Hanami::View
        #   end
        #
        #   template = Hanami::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        def initialize(template, **locals)
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
        # @raise [Hanami::View::MissingTemplateError] if the template is nil
        #
        # @since 0.1.0
        #
        # @see Hanami::View::Layout
        #
        # @example with template
        #   require 'hanami/view'
        #
        #   class IndexView
        #     include Hanami::View
        #   end
        #
        #   template = Hanami::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        #
        #   view.render # => <h1>Introducing Hanami::view</h1> ...
        #
        # @example with template and layout
        #   require 'hanami/view'
        #
        #   class ApplicationLayout
        #     include Hanami::View::Layout
        #   end
        #
        #   class IndexView
        #     include Hanami::View
        #     layout :application
        #   end
        #
        #   template = Hanami::View::Template.new('index.html.erb')
        #   view     = IndexView.new(template, {article: article})
        #
        #   view.render # => <html> ... <h1>Introducing Hanami::view</h1> ...
        #
        # @example with custom rendering
        #   require 'hanami/view'
        #
        #   class IndexView
        #     include Hanami::View
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

        # It tries to invoke a method for the view or a local for the given key.
        # If the lookup fails, it returns a null object.
        #
        # @return [Object,Hanami::View::Rendering::NullLocal] the returning value
        #
        # @since 0.7.0
        #
        # @example
        #   <% if local(:plan).overdue? %>
        #     <h2>Your plan is overdue.</h2>
        #   <% end %>
        def local(key)
          if respond_to?(key)
            __send__(key)
          else
            locals.fetch(key) { NullLocal.new(key) }
          end
        end

        protected
        # The output of the template rendering process.
        #
        # @return [String] the rendering output
        #
        # @raise [Hanami::View::MissingTemplateError] if the template is nil
        #
        # @api private
        # @since 0.1.0
        def rendered
          template.render @scope
        end

        # The layout.
        #
        # @return [Class, Hanami::View::Rendering::NullLayout]
        #
        # @see Hanami::View::Layout
        # @see Hanami::View.layout
        # @see Hanami::View::Dsl#layout
        #
        # @api private
        # @since 0.1.0
        def layout
          @layout ||= self.class.layout.new(@scope, rendered)
        end

        # The template.
        #
        # @return [Hanami::View::Template] the template
        #
        # @raise [Hanami::View::MissingTemplateError] if the template is nil
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
        # @see Hanami::View#initialize
        #
        # @api private
        # @since 0.1.0
        def locals
          @locals
        end

        # Delegates missing methods to the scope.
        #
        # @see Hanami::View::Rendering::Scope
        #
        # @api private
        # @since 0.1.0
        #
        # @example
        #   require 'hanami/view'
        #
        #   class IndexView
        #     include Hanami::View
        #   end
        #
        #   template = Hanami::View::Template.new('index.html.erb')
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
      # @raise [Hanami::View::MissingTemplateError] if it can't find a template
      #   for the given context
      #
      # @raise [Hanami::View::MissingFormatError] if the given context doesn't
      #   have the :format key
      #
      # @since 0.1.0
      #
      # @see Hanami::View#initialize
      # @see Hanami::View#render
      #
      # @example
      #   require 'hanami/view'
      #
      #   article = OpenStruct.new(title: 'Hello')
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
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
      #   Hanami::View.root = '/path/to/templates'
      #   Hanami::View.load!
      #
      #   Articles::Show.render(format: :html,  article: article)
      #     # => renders `articles/show.html.erb`
      #
      #   Articles::Show.render(format: :json, article: article)
      #     # => renders `articles/show.json.erb`
      #
      #   Articles::Show.render(format: :xml, article: article)
      #     # => raises Hanami::View::MissingTemplateError
      def render(context)
        registry.resolve(context).render
      end

      protected

      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View.load!
      def load!
        super
        load_registry!
      end

      private

      # The registry that holds all the registered subclasses.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View::Rendering::Registry
      def registry
        @registry ||= Registry.new(self)
      end

      # @api private
      def load_registry!
        @registry = nil
        registry.freeze
      end
    end
  end
end
