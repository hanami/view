require_relative "scope"

module Hanami
  class View
    module StandaloneView
      def self.included(klass)
        klass.extend ClassMethods
        klass.include InstanceMethods
      end

      module ClassMethods
        # @api private
        def inherited(klass)
          super

          exposures.each do |name, exposure|
            klass.exposures.import(name, exposure)
          end
        end

        # @!group Exposures

        # @!macro [new] exposure_options
        #   @param options [Hash] the exposure's options
        #   @option options [Boolean] :layout expose this value to the layout (defaults to false)
        #   @option options [Boolean] :decorate decorate this value in a matching Part (defaults to
        #     true)
        #   @option options [Symbol, Class] :as an alternative name or class to use when finding a
        #     matching Part

        # @overload expose(name, **options, &block)
        #   Define a value to be passed to the template. The return value of the
        #   block will be decorated by a matching Part and passed to the template.
        #
        #   The block will be evaluated with the view instance as its `self`. The
        #   block's parameters will determine what it is given:
        #
        #   - To receive other exposure values, provide positional parameters
        #     matching the exposure names. These exposures will already by decorated
        #     by their Parts.
        #   - To receive the view's input arguments (whatever is passed to
        #     `View#call`), provide matching keyword parameters. You can provide
        #     default values for these parameters to make the corresponding input
        #     keys optional
        #   - To receive the Context object, provide a `context:` keyword parameter
        #   - To receive the view's input arguments in their entirety, provide a
        #     keywords splat parameter (i.e. `**input`)
        #
        #   @example Accessing input arguments
        #     expose :article do |slug:|
        #       article_repo.find_by_slug(slug)
        #     end
        #
        #   @example Accessing other exposures
        #     expose :articles do
        #       article_repo.listing
        #     end
        #
        #     expose :featured_articles do |articles|
        #       articles.select(&:featured?)
        #     end
        #
        #   @param name [Symbol] name for the exposure
        #   @macro exposure_options
        #
        # @overload expose(name, **options)
        #   Define a value to be passed to the template, provided by an instance
        #   method matching the name. The method's return value will be decorated by
        #   a matching Part and passed to the template.
        #
        #   The method's parameters will determine what it is given:
        #
        #   - To receive other exposure values, provide positional parameters
        #     matching the exposure names. These exposures will already by decorated
        #     by their Parts.
        #   - To receive the view's input arguments (whatever is passed to
        #     `View#call`), provide matching keyword parameters. You can provide
        #     default values for these parameters to make the corresponding input
        #     keys optional
        #   - To receive the Context object, provide a `context:` keyword parameter
        #   - To receive the view's input arguments in their entirey, provide a
        #     keywords splat parameter (i.e. `**input`)
        #
        #   @example Accessing input arguments
        #     expose :article
        #
        #     def article(slug:)
        #       article_repo.find_by_slug(slug)
        #     end
        #
        #   @example Accessing other exposures
        #     expose :articles
        #     expose :featured_articles
        #
        #     def articles
        #       article_repo.listing
        #     end
        #
        #     def featured_articles
        #       articles.select(&:featured?)
        #     end
        #
        #   @param name [Symbol] name for the exposure
        #   @macro exposure_options
        #
        # @overload expose(name, **options)
        #   Define a single value to pass through from the input data (when there is
        #   no instance method matching the `name`). This value will be decorated by
        #   a matching Part and passed to the template.
        #
        #   @param name [Symbol] name for the exposure
        #   @macro exposure_options
        #   @option options [Boolean] :default a default value to provide if there is no matching
        #     input data
        #
        # @overload expose(*names, **options)
        #   Define multiple values to pass through from the input data (when there
        #   is no instance methods matching their names). These values will be
        #   decorated by matching Parts and passed through to the template.
        #
        #   The provided options will be applied to all the exposures.
        #
        #   @param names [Symbol] names for the exposures
        #   @macro exposure_options
        #   @option options [Boolean] :default a default value to provide if there is no matching
        #     input data
        #
        # @see https://dry-rb.org/gems/dry-view/exposures/
        #
        # @api public
        def expose(*names, **options, &block)
          if names.length == 1
            exposures.add(names.first, block, **options)
          else
            names.each do |name|
              exposures.add(name, **options)
            end
          end
        end

        # @api public
        def private_expose(*names, **options, &block)
          expose(*names, **options, private: true, &block)
        end

        # Returns the defined exposures. These are unbound, since bound exposures
        # are only created when initializing a View instance.
        #
        # @return [Exposures]
        # @api private
        def exposures
          @exposures ||= Exposures.new
        end

        # @!endgroup

        # @!group Scope

        # Creates and assigns a scope for the current view.
        #
        # The newly created scope is useful to add custom logic that is specific
        # to the view.
        #
        # The scope has access to locals, exposures, and inherited scope (if any)
        #
        # If the view already has an explicit scope the newly created scope will
        # inherit from the explicit scope.
        #
        # There are two cases when this may happen:
        #   1. The scope was explicitly assigned (e.g. `config.scope = MyScope`)
        #   2. The scope has been inherited by the view superclass
        #
        # If the view doesn't have an already existing scope, the newly scope
        # will inherit from `Hanami::View::Scope` by default.
        #
        # However, you can specify any base class for it. This is not
        # recommended, unless you know what you're doing.
        #
        # @param scope [Hanami::View::Scope] the current scope (if any), or the
        #   default base class will be `Hanami::View::Scope`
        # @param block [Proc] the scope logic definition
        #
        # @api public
        #
        # @example Basic usage
        #   class MyView < Hanami::View
        #     config.scope = MyScope
        #
        #     scope do
        #       def greeting
        #         _locals[:message].upcase + "!"
        #       end
        #
        #       def copyright(time)
        #         "Copy #{time.year}"
        #       end
        #     end
        #   end
        #
        #   # my_view.html.erb
        #   # <%= greeting %>
        #   # <%= copyright(Time.now.utc) %>
        #
        #   MyView.new.(message: "Hello") # => "HELLO!"
        #
        # @example Inherited scope
        #   class MyScope < Hanami::View::Scope
        #     private
        #
        #     def shout(string)
        #       string.upcase + "!"
        #     end
        #   end
        #
        #   class MyView < Hanami::View
        #     config.scope = MyScope
        #
        #     scope do
        #       def greeting
        #         shout(_locals[:message])
        #       end
        #
        #       def copyright(time)
        #         "Copy #{time.year}"
        #       end
        #     end
        #   end
        #
        #   # my_view.html.erb
        #   # <%= greeting %>
        #   # <%= copyright(Time.now.utc) %>
        #
        #   MyView.new.(message: "Hello") # => "HELLO!"
        def scope(base: config.scope || Hanami::View::Scope, &block)
          config.scope = Class.new(base, &block)
        end

        # @!endgroup

        # @!group Render environment

        # Returns a render environment for the view and the given options. This
        # environment isn't chdir'ed into any particular directory.
        #
        # @param format [Symbol] template format to use (defaults to the `default_format` setting)
        # @param context [Context] context object to use (defaults to the `default_context` setting)
        #
        # @see View.template_env render environment for the view's template
        # @see View.layout_env render environment for the view's layout
        #
        # @return [RenderEnvironment]
        # @api public
        def render_env(format: config.default_format, context: config.default_context)
          RenderEnvironment.prepare(renderer(format), config, context)
        end

        # @overload template_env(format: config.default_format, context: config.default_context)
        #   Returns a render environment for the view and the given options,
        #   chdir'ed into the view's template directory. This is the environment
        #   used when rendering the template, and is useful to to fetch
        #   independently when unit testing Parts and Scopes.
        #
        #   @param format [Symbol] template format to use (defaults to the `default_format` setting)
        #   @param context [Context] context object to use (defaults to the `default_context` setting)
        #
        #   @return [RenderEnvironment]
        #   @api public
        def template_env(**args)
          render_env(**args).chdir(config.template)
        end

        # @overload layout_env(format: config.default_format, context: config.default_context)
        #   Returns a render environment for the view and the given options,
        #   chdir'ed into the view's layout directory. This is the environment used
        #   when rendering the view's layout.
        #
        #   @param format [Symbol] template format to use (defaults to the `default_format` setting)
        #   @param context [Context] context object to use (defaults to the `default_context` setting)
        #
        #   @return [RenderEnvironment] @api public
        def layout_env(**args)
          render_env(**args).chdir(layout_path)
        end

        # Returns renderer for the view and provided format
        #
        # @api private
        def renderer(format)
          fetch_or_store(:renderer, config, format) {
            Renderer.new(
              config.paths,
              format: format,
              engine_mapping: config.renderer_engine_mapping,
              **config.renderer_options
            )
          }
        end

        # @api private
        def layout_path
          File.join(*[config.layouts_dir, config.layout].compact)
        end

        # @!endgroup
      end

      module InstanceMethods
        # Returns an instance of the view. This binds the defined exposures to the
        # view instance.
        #
        # Subclasses can define their own `#initialize` to accept injected
        # dependencies, but must call `super()` to ensure the standard view
        # initialization can proceed.
        #
        # @api public
        def initialize
          @exposures = self.class.exposures.bind(self)
        end

        # The view's configuration
        #
        # @api private
        def config
          self.class.config
        end

        # The view's bound exposures
        #
        # @return [Exposures]
        # @api private
        def exposures
          @exposures
        end

        # Render the view
        #
        # @param format [Symbol] template format to use
        # @param context [Context] context object to use
        # @param input input data for preparing exposure values
        #
        # @return [Rendered] rendered view object
        # @api public
        def call(format: config.default_format, context: config.default_context, **input)
          ensure_config

          env = self.class.render_env(format: format, context: context)
          template_env = self.class.template_env(format: format, context: context)

          locals = locals(template_env, input)
          output = env.template(config.template, template_env.scope(config.scope, locals))

          if layout?
            layout_env = self.class.layout_env(format: format, context: context)
            begin
              output = env.template(
                self.class.layout_path,
                layout_env.scope(config.scope, layout_locals(locals))
              ) { output }
            rescue TemplateNotFoundError
              raise LayoutNotFoundError.new(config.layout, config.paths)
            end
          end

          Rendered.new(output: output, locals: locals)
        end

        private

        # @api private
        def ensure_config
          raise UndefinedConfigError, :paths unless Array(config.paths).any?
          raise UndefinedConfigError, :template unless config.template
        end

        # @api private
        def locals(render_env, input)
          exposures.(context: render_env.context, **input) do |value, exposure|
            if exposure.decorate? && value
              render_env.part(exposure.name, value, **exposure.options)
            else
              value
            end
          end
        end

        # @api private
        def layout_locals(locals)
          locals.each_with_object({}) do |(key, value), layout_locals|
            layout_locals[key] = value if exposures[key].for_layout?
          end
        end

        # @api private
        def layout?
          !!config.layout # rubocop:disable Style/DoubleNegation
        end
      end
    end
  end
end
