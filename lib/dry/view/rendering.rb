module Dry
  module View
    class Rendering
      def self.prepare(renderer, config, context)
        new(
          renderer: renderer,
          inflector: config.inflector,
          context: context,
          scope_builder: config.scope_builder.new(namespace: config.scope_namespace),
          part_builder: config.part_builder.new(namespace: config.part_namespace),
        )
      end

      attr_reader :renderer, :inflector, :context, :scope_builder, :part_builder

      def initialize(renderer:, inflector:, context:, scope_builder:, part_builder:)
        @renderer = renderer
        @inflector = inflector
        @context = context.for_rendering(self)
        @scope_builder = scope_builder.for_rendering(self)
        @part_builder = part_builder.for_rendering(self)
      end

      def part(name, value, **options)
        part_builder.(name, value, **options)
      end

      def scope(name = nil, locals)
        scope_builder.(name, locals)
      end

      def template(name, scope, &block)
        renderer.template(name, scope, &block)
      end

      def partial(name, scope, &block)
        renderer.partial(name, scope, &block)
      end

      def chdir(dirname)
        self.class.new(
          renderer: renderer.chdir(dirname),
          inflector: inflector,
          context: context,
          scope_builder: scope_builder,
          part_builder: part_builder,
        )
      end
    end
  end
end
