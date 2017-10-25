require 'hanami/view/rendering/null_local'
require 'hanami/utils/escape'

module Hanami
  module View
    module Rendering
      # List of render types that exactly one of must be included when calling `#render`.
      # For example, when calling `<%= render something: 'my_thing', locals: {} %>`,
      # 'something' must be one of the values listed here.
      #
      # @since 1.1.0
      # @api private
      KNOWN_RENDER_TYPES = [:partial, :template].freeze

      # Scope for layout rendering
      #
      # @since 0.1.0
      class LayoutScope < BasicObject
        # Initialize the scope
        #
        # @param layout [Hanami::Layout] the layout to render
        # @param scope [Hanami::View::Rendering::Scope] the scope of the current
        #   view
        #
        # @api private
        # @since 0.1.0
        def initialize(layout, scope)
          @layout = layout
          @scope  = scope
          @view   = nil
          @locals = nil
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
        # @raise [Hanami::Error::UnknownRenderTypeError] if the given type to
        #   be rendered is unknown
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
        # @return [Hanami::View] the current view
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

        # It tries to invoke a method for the view or a local for the given key.
        # If the lookup fails, it returns a null object.
        #
        # @return [Object,Hanami::View::Rendering::NullLocal] the returning value
        #
        # @since 0.7.0
        #
        # @example Safe method navigation
        #   <% if local(:plan).overdue? %>
        #     <h2>Your plan is overdue.</h2>
        #   <% end %>
        #
        # @example Optional Contents
        #   # Given the following layout template
        #
        #   <!doctype HTML>
        #   <html>
        #     <!-- ... -->
        #     <body>
        #       <!-- ... -->
        #       <%= local :footer %>
        #     </body>
        #   </html>
        #
        #   # Case 1:
        #   #   Products::Index doesn't respond to #footer, local will return nil
        #   #
        #   # Case 2:
        #   #   Products::Show responds to #footer, local will send back
        #   #     #footer returning value
        #
        #   module Products
        #     class Index
        #       include Hanami::View
        #     end
        #
        #     class Show
        #       include Hanami::View
        #
        #       def footer
        #         "contents for footer"
        #       end
        #     end
        #   end
        def local(key)
          if respond_to?(key)
            __send__(key)
          else
            locals.fetch(key) { NullLocal.new(key) }
          end
        end

        # Implements "respond to" logic
        #
        # @return [TrueClass,FalseClass]
        #
        # @since 0.3.0
        # @api private
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
        # @see Hanami::View::Rendering::Scope
        # @see Hanami::Layout
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
          # FIXME: this isn't compatible with Hanami 2.0, as it extends a view
          # that we want to be frozen in the future
          #
          # See https://github.com/hanami/view/issues/130#issuecomment-319326236
          if @scope.respond_to?(m, true)
            @scope.__send__(m, *args, &blk)
          elsif layout.respond_to?(m)
            layout.__send__(m, *args, &blk)
          else
            ::Hanami::View::Escape.html(super)
          end
        end

        # @api private
        def renderer(options)
          if options[:partial]
            Rendering::Partial
          elsif options[:template]
            Rendering::Template
          else
            ::Kernel.raise UnknownRenderTypeError.new(KNOWN_RENDER_TYPES, options)
          end.new(view, _options(options))
        end

        private
        # @api private
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
