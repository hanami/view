require 'dry/configurable'
require "dry/core/cache"
require 'dry/equalizer'
require 'dry/inflector'

require_relative 'view/context'
require_relative 'view/exposures'
require_relative 'view/part_builder'
require_relative 'view/path'
require_relative 'view/render_environment'
require_relative 'view/rendered'
require_relative 'view/renderer'
require_relative 'view/scope_builder'

module Dry
  class View
    extend Dry::Core::Cache

    UndefinedTemplateError = Class.new(StandardError)

    DEFAULT_RENDERER_OPTIONS = {default_encoding: 'utf-8'.freeze}.freeze

    include Dry::Equalizer(:config, :exposures)

    extend Dry::Configurable

    setting :paths
    setting :layout, false
    setting :layouts_dir, "layouts".freeze
    setting :template

    setting :default_format, :html
    setting :renderer_engine_mapping
    setting :renderer_options, DEFAULT_RENDERER_OPTIONS do |options|
      DEFAULT_RENDERER_OPTIONS.merge(options.to_h).freeze
    end

    setting :default_context, Context.new.freeze

    setting :scope

    setting :inflector, Dry::Inflector.new

    setting :part_builder, PartBuilder
    setting :part_namespace

    setting :scope_builder, ScopeBuilder
    setting :scope_namespace

    # @api private
    def self.inherited(klass)
      super
      exposures.each do |name, exposure|
        klass.exposures.import(name, exposure)
      end
    end

    # @api public
    def self.paths
      Array(config.paths).map { |path| Path.new(path) }
    end

    # @api private
    def self.layout_path
      File.join(config.layouts_dir, config.layout)
    end

    # @api public
    def self.render_env(format: config.default_format, context: config.default_context)
      RenderEnvironment.prepare(renderer(format), config, context)
    end

    # @api public
    def self.template_env(**args)
      render_env(**args).chdir(config.template)
    end

    # @api public
    def self.layout_env(**args)
      render_env(**args).chdir(layout_path)
    end

    # @api private
    def self.renderer(format)
      fetch_or_store(:renderer, config, format) {
        Renderer.new(
          paths,
          format: format,
          engine_mapping: config.renderer_engine_mapping,
          **config.renderer_options,
        )
      }
    end

    # @api public
    def self.expose(*names, **options, &block)
      if names.length == 1
        exposures.add(names.first, block, options)
      else
        names.each do |name|
          exposures.add(name, options)
        end
      end
    end

    # @api public
    def self.private_expose(*names, **options, &block)
      expose(*names, **options, private: true, &block)
    end

    # @api private
    def self.exposures
      @exposures ||= Exposures.new
    end

    attr_reader :exposures

    # @api public
    def initialize
      @exposures = self.class.exposures.bind(self)
    end

    # @api public
    def config
      self.class.config
    end

    # @api public
    def call(format: config.default_format, context: config.default_context, **input)
      raise UndefinedTemplateError, "no +template+ configured" unless config.template

      env = self.class.render_env(format: format, context: context)
      template_env = self.class.template_env(format: format, context: context)

      locals = locals(template_env, input)
      output = env.template(config.template, template_env.scope(config.scope, locals))

      if layout?
        layout_env = self.class.layout_env(format: format, context: context)
        output = layout_env.template(self.class.layout_path, layout_env.scope(config.scope, layout_locals(locals))) { output }
      end

      Rendered.new(output: output, locals: locals)
    end

    private

    def locals(render_env, input)
      exposures.(context: render_env.context, **input) do |value, exposure|
        if exposure.decorate? && value
          render_env.part(exposure.name, value, **exposure.options)
        else
          value
        end
      end
    end

    def layout_locals(locals)
      locals.each_with_object({}) do |(key, value), layout_locals|
        layout_locals[key] = value if exposures[key].for_layout?
      end
    end

    def layout?
      !!config.layout
    end
  end
end
