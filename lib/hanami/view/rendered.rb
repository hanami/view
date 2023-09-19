# frozen_string_literal: true

require "dry/core/equalizer"

module Hanami
  class View
    # Output of a View rendering
    #
    # @api public
    class Rendered
      include Dry::Equalizer(:output, :locals)

      # Returns the rendered view
      #
      # @return [String]
      #
      # @api public
      attr_reader :output

      # Returns the hash of locals used to render the view
      #
      # @return [Hash[<Symbol, Hanami::View::Part>] locals hash
      #
      # @api public
      attr_reader :locals

      # @api private
      def initialize(output:, locals:)
        @output = output
        @locals = locals
      end

      # Returns the local corresponding to the key
      #
      # @param name [Symbol] local key
      #
      # @return [Hanami::View::Part]
      #
      # @api public
      def [](name)
        locals[name]
      end

      # Returns the rendered view
      #
      # @return [String]
      #
      # @api public
      def to_s
        output
      end
      alias_method :to_str, :to_s

      # Matches given input with the rendered view
      #
      # @param matcher [String, Regexp] matcher
      #
      # @return [TrueClass,FalseClass]
      #
      # @api public
      # @since 2.1.0
      def match?(matcher)
        output.match?(matcher)
      end
      alias_method :match, :match?

      # Checks if given string is included in the rendered view
      #
      # @param string [String] string
      #
      # @return [TrueClass,FalseClass]
      #
      # @api public
      # @since 2.1.0
      def include?(string)
        output.include?(string)
      end
    end
  end
end
