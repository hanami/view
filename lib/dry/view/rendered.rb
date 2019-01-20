require 'dry/equalizer'

module Dry
  class View
    class Rendered
      include Dry::Equalizer(:output, :locals)

      attr_reader :output
      attr_reader :locals

      def initialize(output:, locals:)
        @output = output
        @locals = locals
      end

      def [](name)
        locals[name]
      end

      def to_s
        output
      end
      alias_method :to_str, :to_s
    end
  end
end
