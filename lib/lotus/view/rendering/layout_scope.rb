module Lotus
  module View
    module Rendering
      # Scope for layout rendering
      #
      # @since 0.1.0
      class LayoutScope < BasicObject
        # Initialize the scope
        #
        # @param layout [Lotus::Layout] the layout to render
        # @param scope [Lotus::View::Rendering::Scope] the scope of the current
        #   view
        #
        # @api private
        # @since 0.1.0
        def initialize(layout, scope)
          @layout, @scope = layout, scope
        end

        # Render a partial or a template within a layout template.
        #
        # @param options [Hash]
        # @option options [String] :partial the partial template to render
        # @option options [String] :template the template to render
        #
        # @return [String] the output of the rendering process
        #
        # @since 0.1.0
        #
        # @example Rendering partial
        #   # Given a partial under:
        #   #   templates/shared/_sidebar.html.erb
        #   #
        #   # In the layout template:
        #   #   templates/application.html.erb
        #   #
        #   # Use like this:
        #   <%= render partial: 'shared/sidebar' %>
        #
        # @example Rendering template
        #   # Given a template under:
        #   #   templates/articles/index.html.erb
        #   #
        #   # In the layout template:
        #   #   templates/application.html.erb
        #   #
        #   # Use like this:
        #   <%= render template: 'articles/index' %>
        #
        # @example Rendering partial, using optional :locals
        #   # Given a partial under:
        #   #   templates/shared/_sidebar.html.erb
        #   #
        #   # In the layout template:
        #   #   templates/application.html.erb
        #   #
        #   # Use like this:
        #   <%= render partial: 'shared/sidebar', { user: current_user } %>
        #
        #   #
        #   # `user` will be available in the scope of the sidebar rendering
        def render(options)
          renderer(options).render
        end

        # Returns the requested format.
        #
        # @return [Symbol] the requested format (eg. :html, :json, :xml, etc..)
        #
        # @since 0.1.0
        def format
          @scope.format
        end

        # The current view.
        #
        # @return [Lotus::View] the current view
        #
        # @since 0.1.0
        def view
          @view || @scope.view
        end

        # The current locals.
        #
        # @return [Hash] the current locals
        #
        # @since 0.1.0
        def locals
          @locals || @scope.locals
        end

        protected
        # Forward all the missing methods to the view scope or to the layout.
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Rendering::Scope
        # @see Lotus::Layout
        #
        # @example
        #   # In the layout template:
        #   #   templates/application.html.erb
        #   #
        #   # Use like this:
        #   <title><%= article.title %></title>
        #
        #   # `article` will be looked up in the view scope first.
        #   # If not found, it will be searched within the layout.
        def method_missing(m)
          begin
            @scope.__send__ m
          rescue
            @layout.__send__ m
          end
        end

        def renderer(options)
          if options[:partial]
            Rendering::Partial
          elsif options[:template]
            Rendering::Template
          end.new(view, _options(options))
        end

        private
        def _options(options)
          options.dup.tap do |opts|
            opts.merge!(format: format)
            opts[:locals] = locals
            opts[:locals].merge!(options.fetch(:locals){ ::Hash.new })
          end
        end
      end
    end
  end
end
