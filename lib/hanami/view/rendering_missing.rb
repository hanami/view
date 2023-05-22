require "dry/inflector"
require_relative "errors"

module Hanami
  class View
    # @api private
    class RenderingMissing
      def format
        raise RenderingMissingError
      end

      def context
        raise RenderingMissingError
      end

      def part(_name, _value, **_options)
        raise RenderingMissingError
      end

      def scope(_name = nil, _locals) # rubocop:disable Style/OptionalArguments
        raise RenderingMissingError
      end

      def template(_name, _scope)
        raise RenderingMissingError
      end

      def partial(_name, _scope)
        raise RenderingMissingError
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end
    end
  end
end
