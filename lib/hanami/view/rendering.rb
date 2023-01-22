# frozen_string_literal: true

# require "dry/core/equalizer"
require_relative "renderer"

module Hanami
  class View
    # @api private
    class Rendering
      attr_reader :config, :format, :context

      attr_reader :inflector, :renderer, :part_builder, :scope_builder

      def initialize(config, format, context)
        @format = format
        @context = context.for_rendering(self)
        @inflector = config.inflector

        @renderer = Renderer.new(config)
        @part_builder = config.part_builder.new(namespace: config.part_namespace, rendering: self)
        @scope_builder = config.scope_builder.new(namespace: config.scope_namespace, rendering: self)
      end

      def template(name, scope, &block)
        renderer.template(name, format, scope, &block)
      end

      def partial(name, scope, &block)
        renderer.partial(name, format, scope, &block)
      end

      def part(name, value, as: nil)
        part_builder.(name, value, as: as)
      end

      def scope(name = nil, locals) # rubocop:disable Style/OptionalArguments
        scope_builder.(name, locals)
      end
    end
  end
end
