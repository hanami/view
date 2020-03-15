# frozen_string_literal: true

require "dry/configurable"
require "dry/core/cache"
require "dry/equalizer"
require "dry/inflector"

require_relative "view/context"
require_relative "view/exposures"
require_relative "view/errors"
require_relative "view/part_builder"
require_relative "view/path"
require_relative "view/render_environment"
require_relative "view/rendered"
require_relative "view/renderer"
require_relative "view/scope_builder"

module Hanami
  # A standalone, template-based view rendering system that offers everything
  # you need to write well-factored view code.
  #
  # This represents a single view, holding the configuration and exposures
  # necessary for rendering its template.
  #
  # @abstract Subclass this and provide your own configuration and exposures to
  #   define your own view (along with a custom `#initialize` if you wish to
  #   inject dependencies into your subclass)
  #
  # @see https://dry-rb.org/gems/dry-view/
  #
  # @api public
  class View
    # @api private
    DEFAULT_RENDERER_OPTIONS = {default_encoding: "utf-8"}.freeze

    include Dry::Equalizer(:config, :exposures)

    extend Dry::Core::Cache

    extend Dry::Configurable

    # @!group Configuration

    # @overload config.paths=(paths)
    #   Set an array of directories that will be searched for all templates
    #   (templates, partials, and layouts).
    #
    #   These will be converted into Path objects and used for template lookup
    #   when rendering.
    #
    #   This is a **required setting**.
    #
    #   @param paths [String, Path, Array<String, Path>] the paths
    #
    #   @api public
    # @!scope class
    setting :paths do |paths|
      Array(paths).map { |path| Path[path] }
    end

    # @overload config.template=(name)
    #   Set the name of the template for rendering this view. Template name
    #   should be relative to the configured `paths`.
    #
    #   This is a **required setting**.
    #
    #   @param name [String] template name
    #   @api public
    # @!scope class
    setting :template

    # @overload config.layout=(name)
    #   Set the name of the layout to render templates within. Layouts will be
    #   looked up within the configured `layouts_dir`, within the configured
    #   `paths`.
    #
    #   A false or nil value will use no layout. Defaults to `nil`.
    #
    #   @param name [String, FalseClass, nil] layout name, or false to indicate no layout
    #   @api public
    # @!scope class
    setting :layout, false

    # @overload config.layouts_dir=(dir)
    #   Set the name of the directory (within the configured `paths`) holding
    #   the layouts. Defaults to `"layouts"`
    #
    #   @param dir [String] directory name
    #   @api public
    # @!scope class
    setting :layouts_dir, "layouts"

    # @overload config.scope=(scope_class)
    #   Set the scope class to use when rendering the view's template.
    #
    #   Configuring a custom scope class allows you to provide extra behaviour
    #   (alongside exposures) to the template.
    #
    #   @see https://dry-rb.org/gems/dry-view/scopes/
    #
    #   @param scope_class [Class] scope class (inheriting from `Hanami::View::Scope`)
    #   @api public
    # @!scope class
    setting :scope

    # @overload config.default_context=(context)
    #   Set the default context object to use when rendering. This will be used
    #   unless another context object is applied at render-time to `View#call`
    #
    #   Defaults to a frozen instance of `Hanami::View::Context`.
    #
    #   @see View#call
    #
    #   @param context [Hanami::View::Context] context object
    #   @api public
    # @!scope class
    setting :default_context, Context.new.freeze

    # @overload config.default_format=(format)
    #   Set the default format to use when rendering.
    #
    #   Defaults to `:html`.
    #
    #   @param format [Symbol]
    #   @api public
    # @!scope class
    setting :default_format, :html

    # @overload config.scope_namespace=(namespace)
    #   Set a namespace that will be searched when building scope classes.
    #
    #   @param namespace [Module, Class]
    #
    #   @see Scope
    #
    #   @api public
    # @!scope class
    setting :part_namespace

    # @overload config.part_builder=(part_builder)
    #   Set a custom part builder class
    #
    #   @see https://dry-rb.org/gems/dry-view/parts/
    #
    #   @param part_builder [Class]
    #   @api public
    # @!scope class
    setting :part_builder, PartBuilder

    # @overload config.scope_namespace=(namespace)
    #   Set a namespace that will be searched when building scope classes.
    #
    #   @param namespace [Module, Class]
    #
    #   @see Scope
    #
    #   @api public
    # @!scope class
    setting :scope_namespace

    # @overload config.scope_builder=(scope_builder)
    #   Set a custom scope builder class
    #
    #   @see https://dry-rb.org/gems/dry-view/scopes/
    #
    #   @param scope_builder [Class]
    #   @api public
    # @!scope class
    setting :scope_builder, ScopeBuilder

    # @overload config.inflector=(inflector)
    #   Set an inflector to provide to the part_builder and scope_builder.
    #
    #   Defaults to `Dry::Inflector.new`.
    #
    #   @param inflector
    #   @api public
    # @!scope class
    setting :inflector, Dry::Inflector.new

    # @overload config.renderer_options=(options)
    #   A hash of options to pass to the template engine. Template engines are
    #   provided by Tilt; see Tilt's documentation for what options your
    #   template engine may support.
    #
    #   Defaults to `{default_encoding: "utf-8"}`. Any options passed will be
    #   merged onto the defaults.
    #
    #   @see https://github.com/rtomayko/tilt
    #
    #   @param options [Hash] renderer options
    #   @api public
    # @!scope class
    setting :renderer_options, DEFAULT_RENDERER_OPTIONS do |options|
      DEFAULT_RENDERER_OPTIONS.merge(options.to_h).freeze
    end

    # @overload config.renderer_engine_mapping=(mapping)
    #   A hash specifying the (Tilt-compatible) template engine class to use
    #   for a given format. Template engine detection is automatic based on
    #   format; use this setting only if you want to force a non-preferred
    #   engine.
    #
    #   @example
    #     config.renderer_engine_mapping = {erb: Tilt::ErubiTemplate}
    #
    #   @see https://github.com/rtomayko/tilt
    #
    #   @param mapping [Hash<Symbol, Class>] engine mapping
    #   @api public
    # @!scope class
    setting :renderer_engine_mapping

    # @!endgroup

    # @api private
    def self.inherited(klass)
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
    def self.expose(*names, **options, &block)
      if names.length == 1
        exposures.add(names.first, block, **options)
      else
        names.each do |name|
          exposures.add(name, **options)
        end
      end
    end

    # @api public
    def self.private_expose(*names, **options, &block)
      expose(*names, **options, private: true, &block)
    end

    # Returns the defined exposures. These are unbound, since bound exposures
    # are only created when initializing a View instance.
    #
    # @return [Exposures]
    # @api private
    def self.exposures
      @exposures ||= Exposures.new
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
    def self.render_env(format: config.default_format, context: config.default_context)
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
    def self.template_env(**args)
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
    def self.layout_env(**args)
      render_env(**args).chdir(layout_path)
    end

    # Returns renderer for the view and provided format
    #
    # @api private
    def self.renderer(format)
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
    def self.layout_path
      File.join(config.layouts_dir, config.layout)
    end

    # @!endgroup

    # The view's bound exposures
    #
    # @return [Exposures]
    # @api private
    attr_reader :exposures

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
        output = env.template(
          self.class.layout_path,
          layout_env.scope(config.scope, layout_locals(locals))
        ) { output }
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
