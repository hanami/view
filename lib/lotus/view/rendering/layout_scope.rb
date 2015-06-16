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

        # Returns the classname as string
        #
        # @return classname
        #
        # @since 0.3.0
        def class
          (class << self; self end).superclass
        end

        # Returns an inspect String
        #
        # @return [String] inspect String (contains classname, objectid in hex, available ivars)
        #
        # @since 0.3.0
        def inspect
          base = "#<#{ self.class }:#{'%x' % (self.object_id << 1)}"
          base << " @layout=\"#{@layout.inspect}\"" if @layout
          base << " @scope=\"#{@scope.inspect}\"" if @scope
          base << ">"
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

        # Returns a content for the given key, by trying to invoke on the current
        # scope, a method with the same name.
        #
        # The scope is made of locals and concrete methods from view and layout.
        #
        # @param key [Symbol] a method to invoke within current scope
        # @return [String,NilClass] returning content if scope respond to the
        #   requested method
        #
        # @since 0.4.1
        #
        # @example
        #   # Given the following layout template
        #
        #   <!doctype HTML>
        #   <html>
        #     <!-- ... -->
        #     <body>
        #       <!-- ... -->
        #       <%= content :footer %>
        #     </body>
        #   </html>
        #
        #   # Case 1:
        #   #   Products::Index doesn't respond to #footer, content will return nil
        #   #
        #   # Case 2:
        #   #   Products::Show responds to #footer, content will send back
        #   #     #footer returning value
        #
        #   module Products
        #     class Index
        #       include Lotus::View
        #     end
        #
        #     class Show
        #       include Lotus::View
        #
        #       def footer
        #         "contents for footer"
        #       end
        #     end
        #   end
        def content(key)
          __send__(key) if respond_to?(key)
        end

        # Implements "respond to" logic
        #
        # @return [TrueClass,FalseClass]
        #
        # @since 0.3.0
        #
        # @see http://ruby-doc.org/core/Object.html#method-i-respond_to-3F
        def respond_to?(m, include_all = false)
          respond_to_missing?(m, include_all)
        end

        # Implements "respond to" logic
        #
        # @return [TrueClass,FalseClass]
        #
        # @since 0.3.0
        # @api private
        #
        # @see http://ruby-doc.org/core/Object.html#method-i-respond_to_missing-3F
        def respond_to_missing?(m, include_all)
          @layout.respond_to?(m, include_all) ||
            @scope.respond_to?(m, include_all)
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
        def method_missing(m, *args, &blk)
          if @scope.respond_to?(m)
            @scope.__send__(m, *args, &blk)
          elsif layout.respond_to?(m)
            layout.__send__(m, *args, &blk)
          else
            super
          end
        rescue ::NameError
          ::Kernel.raise ::NoMethodError.new("undefined method `#{ m }' for #{ self.inspect }", m)
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

        # @since 0.4.2
        # @api private
        def layout
          @layout || @layout.class.layout.new(@scope, "")
        end
      end
    end
  end
end
