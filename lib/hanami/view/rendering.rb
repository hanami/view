# frozen_string_literal: true

module Hanami
  class View
    # @api private
    # @since 2.1.0
    class Rendering
      # @api private
      # @since 2.1.0
      attr_reader :config, :format

      # @api private
      # @since 2.1.0
      attr_reader :inflector, :part_builder, :scope_builder

      # @api private
      # @since 2.1.0
      attr_reader :context, :renderer

      # @api private
      # @since 2.1.0
      def initialize(config:, format:, context:)
        @config = config
        @format = format

        @inflector = config.inflector
        @part_builder = config.part_builder
        @scope_builder = config.scope_builder

        @context = context.dup_for_rendering(self)
        @renderer = Renderer.new(config)
      end

      # @api private
      # @since 2.1.0
      def template(name, scope, &block)
        renderer.template(name, format, scope, &block)
      end

      # @api private
      # @since 2.1.0
      def partial(name, scope, &block)
        renderer.partial(name, format, scope, &block)
      end

      # @api private
      # @since 2.1.0
      def part(name, value, as: nil)
        part_builder.(name, value, as: as, rendering: self)
      end

      # @api private
      # @since 2.1.0
      def scope(name = nil, locals) # rubocop:disable Style/OptionalArguments
        scope_builder.(name, locals: locals, rendering: self)
      end
    end
  end
end
