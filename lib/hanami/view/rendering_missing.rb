# frozen_string_literal: true

require "dry/inflector"
require_relative "errors"

module Hanami
  class View
    # @api private
    # @since 2.1.0
    class RenderingMissing
      # @api private
      # @since 2.1.0
      def format
        raise RenderingMissingError
      end

      # @api private
      # @since 2.1.0
      def context
        raise RenderingMissingError
      end

      # @api private
      # @since 2.1.0
      def part(_name, _value, **_options)
        raise RenderingMissingError
      end

      # @api private
      # @since 2.1.0
      def scope(_name = nil, _locals) # rubocop:disable Style/OptionalArguments
        raise RenderingMissingError
      end

      # @api private
      # @since 2.1.0
      def template(_name, _scope)
        raise RenderingMissingError
      end

      # @api private
      # @since 2.1.0
      def partial(_name, _scope)
        raise RenderingMissingError
      end

      # @api private
      # @since 2.1.0
      def inflector
        @inflector ||= Dry::Inflector.new
      end
    end
  end
end
