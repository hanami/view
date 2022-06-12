# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/effects"

module Hanami
  class View
    # @api private
    class RenderEnvironment
      include Dry::Effects::Handler.Reader(:render_env)

      def self.prepare(renderer, config, context)
        new(
          renderer: renderer,
          inflector: config.inflector,
          context: context,
          scope_builder: config.scope_builder.new(inflector: config.inflector, namespace: config.scope_namespace),
          part_builder: config.part_builder.new(inflector: config.inflector, namespace: config.part_namespace)
        )
      end

      include Dry::Equalizer(:renderer, :inflector, :context, :scope_builder, :part_builder)

      attr_reader :renderer, :inflector, :context, :scope_builder, :part_builder

      def initialize(renderer:, inflector:, context:, scope_builder:, part_builder:)
        @renderer = renderer
        @inflector = inflector
        @context = context
        @scope_builder = scope_builder
        @part_builder = part_builder
      end

      def format
        renderer.format
      end

      def part(name, value, **options)
        part_builder.(name, value, **options)
      end

      def scope(name = nil, locals) # rubocop:disable Style/OptionalArguments
        scope_builder.(name, locals)
      end

      # def template(name, scope, &block)

      # TODO:
      # - Give this keyword arguments, it's getting out of control
      # - Rename `scope` to `scope_name` to make it clear it's not the fully built scope
      def template(name, scope, locals, &block)
        template_env = chdir(name)
        scope = self.scope(scope, locals)

        with_render_env(template_env) {
          renderer.template(name, scope, &block)
        }
      end

      # TODO: Update this to match how `#template` works and see what the flow-on effects are
      def partial(name, scope, &block)
        renderer.partial(name, scope, &block)
      end

      def chdir(dirname)
        self.class.new(
          renderer: renderer.chdir(dirname),
          inflector: inflector,
          context: context,
          scope_builder: scope_builder,
          part_builder: part_builder
        )
      end
    end
  end
end
