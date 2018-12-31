require 'dry/configurable'
require 'dry/equalizer'
require 'dry/inflector'

require_relative 'context'
require_relative 'exposures'
require_relative 'part_builder'
require_relative 'path'
require_relative 'rendered'
require_relative 'renderer'
require_relative 'rendering'
require_relative 'scope_builder'

module Dry
  module View
    class Controller
      UndefinedTemplateError = Class.new(StandardError)

      DEFAULT_LAYOUTS_DIR = 'layouts'.freeze
      DEFAULT_CONTEXT = Context.new
      DEFAULT_RENDERER_OPTIONS = {default_encoding: 'utf-8'.freeze}.freeze
      EMPTY_LOCALS = {}.freeze

      include Dry::Equalizer(:config)

      extend Dry::Configurable

      setting :paths
      setting :layout, false
      setting :template
      setting :default_format, :html
      setting :renderer_options, DEFAULT_RENDERER_OPTIONS do |options|
        DEFAULT_RENDERER_OPTIONS.merge(options.to_h).freeze
      end
      setting :default_context, DEFAULT_CONTEXT

      setting :scope

      setting :inflector, Dry::Inflector.new

      setting :part_builder, PartBuilder
      setting :part_namespace

      setting :scope_builder, ScopeBuilder
      setting :scope_namespace

      attr_reader :config
      attr_reader :layout_dir
      attr_reader :layout_path
      attr_reader :template_path

      attr_reader :exposures

      # @api private
      def self.inherited(klass)
        super
        exposures.each do |name, exposure|
          klass.exposures.import(name, exposure)
        end
      end

      # @api public
      def self.paths
        Array(config.paths).map { |path| Dry::View::Path.new(path) }
      end

      # @api private
      def self.rendering(format: config.default_format, context: config.default_context)
        Rendering.prepare(renderer(format), config, context)
      end

      # @api private
      def self.renderer(format)
        renderers.fetch(format) {
          renderers[format] = Renderer.new(paths, format: format, **config.renderer_options)
        }
      end

      # @api private
      def self.renderers
        @renderers ||= {}
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

      # @api public
      def initialize
        @config = self.class.config
        @layout_dir = DEFAULT_LAYOUTS_DIR
        @layout_path = "#{layout_dir}/#{config.layout}"
        @template_path = config.template

        @exposures = self.class.exposures.bind(self)
      end

      # @api public
      def call(format: config.default_format, context: config.default_context, **input)
        raise UndefinedTemplateError, "no +template+ configured" unless template_path

        rendering = self.class.rendering(format: format, context: context)
        template_rendering = self.class.rendering(format: format, context: context).chdir(template_path)

        locals = locals(template_rendering, input)
        output = rendering.template(template_path, template_rendering.scope(config.scope, locals))

        if layout?
          layout_rendering = self.class.rendering(format: format, context: context).chdir(layout_path)
          output = layout_rendering.template(layout_path, layout_rendering.scope(config.scope, layout_locals(locals))) { output }
        end

        Rendered.new(output: output, locals: locals)
      end

      private

      def locals(rendering, input)
        exposures.(input) do |value, exposure|
          if exposure.decorate? && value
            rendering.part(exposure.name, value, **exposure.options)
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
end
