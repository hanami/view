# frozen_string_literal: true

require "dry/inflector"

module Hanami
  class View
    # @api private
    class RenderEnvironmentMissing
      class MissingEnvironmentError < StandardError
        def message
          "a +render_env+ must be provided"
        end
      end

      def format
        raise MissingEnvironmentError
      end

      def context
        raise MissingEnvironmentError
      end

      def part(_name, _value, **_options)
        raise MissingEnvironmentError
      end

      def scope(_name = nil, _locals) # rubocop:disable Style/OptionalArguments
        raise MissingEnvironmentError
      end

      def template(_name, _scope)
        raise MissingEnvironmentError
      end

      def partial(_name, _scope)
        raise MissingEnvironmentError
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end
    end
  end
end
