module Dry
  module View
    class Exposure
      attr_reader :block

      def initialize(block)
        # TODO: raise error if block parameters aren't right

        @block = block
      end

      def dependencies
        block.parameters.map(&:last)
      end

      def call(input, locals)
        params = dependencies.map { |name|
          name == :input ? input : locals.fetch(name)
        }

        block.(*params)
      end
    end
  end
end
