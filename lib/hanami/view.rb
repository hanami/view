# frozen_string_literal: true

require "dry/configurable"
require "dry/core/cache"
require "dry/core/equalizer"
require "dry/inflector"

require_relative "view/application_view"
require_relative "view/context"
require_relative "view/exposures"
require_relative "view/errors"
require_relative "view/part_builder"
require_relative "view/path"
require_relative "view/render_environment"
require_relative "view/rendered"
require_relative "view/renderer"
require_relative "view/scope_builder"
require_relative "view/standalone_view"

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

    # @overload config.template_inference_base=(base_path)
    #   Set the base path to strip away when when inferring a view's template
    #   names from its class name.
    #
    #   **This setting only applies for views within an Hanami application.**
    #
    #   For example, given a view `Main::Views::Articles::Index`, in the `Main`
    #   slice, and a template_inference_base of "views", the inferred template
    #   name will be "articles/index".
    #
    #   @param base_path [String, nil] base templates path
    #   @api public
    # @!scope class
    setting :template_inference_base

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

    include StandaloneView

    def self.inherited(subclass)
      super

      # If inheriting directly from Hanami::View within an Hanami app, configure
      # the view for the application
      if subclass.superclass == View && (provider = application_provider(subclass))
        subclass.include ApplicationView.new(provider)
      end
    end

    def self.application_provider(subclass)
      if Hanami.respond_to?(:application?) && Hanami.application?
        Hanami.application.component_provider(subclass)
      end
    end
    private_class_method :application_provider
  end
end
