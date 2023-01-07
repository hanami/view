# frozen_string_literal: true

# require "dry/core/equalizer"
require_relative "renderer"

module Hanami
  class View
    # @api private
    class Rendering
      attr_reader :cache, :config, :format, :context

      attr_reader :inflector, :renderer, :part_builder, :scope_builder

      def initialize(cache, config, format, context)
        @cache = cache
        @config = config
        @format = format
        @context = context.for_render_env(self)

        @inflector = config.inflector

        # Maybe this can be a single instance, and we pass in config, etc.
        @renderer = Renderer.new(
          cache,
          config.paths,
          format: format,
          engine_mapping: config.renderer_engine_mapping,
          **config.renderer_options
        )

        # Maybe these could be single cached instances too, and we use effect for render_env?
        @part_builder = config.part_builder.new(namespace: config.part_namespace, render_env: self)
        @scope_builder = config.scope_builder.new(namespace: config.scope_namespace, render_env: self)
      end

      def template(name, scope, &block)
        renderer.template(name, scope, &block)
      end

      def partial(name, scope, &block)
        renderer.partial(name, scope, &block)
      end

      def part(name, value, **options)
        part_builder.(name, value, **options)
      end

      def scope(name = nil, locals) # rubocop:disable Style/OptionalArguments
        scope_builder.(name, locals)
      end
    end
  end
end
