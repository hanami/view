# frozen_string_literal: true

require_relative "renderer"

module Hanami
  class View
    # @api private
    class Rendering
      attr_reader :format, :context

      attr_reader :inflector, :renderer, :part_builder, :scope_builder

      attr_reader :config
      private :config

      def initialize(config:, format:, context:)
        @config = config
        @format = format
        @context = context.for_rendering(self)
        @inflector = config.inflector

        @renderer = Renderer.new(config)
        @part_builder = config.part_builder.new(config)
        @scope_builder = config.scope_builder.new(config)
      end

      def template(name, scope, &block)
        renderer.template(name, format, scope, &block)
      end

      def partial(name, scope, &block)
        renderer.partial(name, format, scope, &block)
      end

      def part(name, value, as: nil)
        part_builder.(name, value, as: as, rendering: self)
      end

      def scope(name = nil, locals) # rubocop:disable Style/OptionalArguments
        scope_builder.(name, locals: locals, rendering: self)
      end
    end
  end
end
