require 'dry/configurable'
require 'dry/equalizer'
require 'dry/inflector'

require_relative 'exposures'
require_relative 'part_builder'
require_relative 'path'
require_relative 'rendered'
require_relative 'renderer'
require_relative 'scope'

module Dry
  module View
    class Controller
      UndefinedTemplateError = Class.new(StandardError)

      DEFAULT_LAYOUTS_DIR = 'layouts'.freeze
      DEFAULT_CONTEXT = Object.new.freeze
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

      setting :inflector, Dry::Inflector.new

      setting :part_builder, PartBuilder
      setting :part_namespace

      attr_reader :config
      attr_reader :layout_dir
      attr_reader :layout_path
      attr_reader :template_path

      attr_reader :part_builder

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

        @part_builder = config.part_builder.new(
          namespace: config.part_namespace,
          inflector: config.inflector,
        )

        @exposures = self.class.exposures.bind(self)
      end

      # @api public
      def call(format: config.default_format, context: config.default_context, **input)
        raise UndefinedTemplateError, "no +template+ configured" unless template_path

        renderer = self.class.renderer(format)

        locals = locals(renderer.chdir(template_path), context, input)

        output = renderer.template(template_path, template_scope(renderer, context, locals))

        if layout?
          output = renderer.template(layout_path, layout_scope(renderer, context)) { output }
        end

        Rendered.new(output: output, locals: locals)
      end

      private

      def locals(renderer, context, input)
        exposures.(input) do |value, exposure|
          if exposure.decorate?
            decorate_local(renderer, context, exposure.name, value, **exposure.options)
          else
            value
          end
        end
      end

      def layout?
        !!config.layout
      end

      def layout_scope(renderer, context)
        scope(renderer.chdir(layout_dir), context)
      end

      def template_scope(renderer, context, locals)
        scope(renderer.chdir(template_path), context, locals)
      end

      def scope(renderer, context, locals = EMPTY_LOCALS)
        Scope.new(
          renderer: renderer,
          context: context,
          locals: locals,
        )
      end

      def decorate_local(renderer, context, name, value, **options)
        if value
          # Decorate truthy values only
          part_builder.(
            name: name,
            value: value,
            renderer: renderer,
            context: context,
            namespace: config.part_namespace,
            **options,
          )
        else
          value
        end
      end
    end
  end
end
