# frozen_string_literal: true

require 'dry/inflector'

module Dry
  class View
    # @api private
    class RenderEnvironmentMissing
      class MissingEnvironmentError < StandardError
        def message
          'a +render_env+ must be provided'
        end
      end

      def format
        raise MissingEnvironmentError
      end

      def context
        raise MissingEnvironmentError
      end

      def part(name, value, **options)
        raise MissingEnvironmentError
      end

      def scope(name = nil, locals)
        raise MissingEnvironmentError
      end

      def template(name, scope, &block)
        raise MissingEnvironmentError
      end

      def partial(name, scope, &block)
        raise MissingEnvironmentError
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end
    end
  end
end
