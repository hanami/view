module Dry
  module View
    class Exposure
      attr_reader :name
      attr_reader :block
      attr_reader :to_view

      def initialize(name, block, to_view: true)
        # TODO: raise error if block parameters aren't right

        @name = name
        @block = block
        @to_view = to_view
      end

      def bind(obj)
        block ? self : with_block(obj.method(name))
      end

      def dependencies
        block.parameters.map(&:last)
      end

      alias_method :to_view?, :to_view

      def call(input, locals)
        params = dependencies.map { |name|
          name == :input ? input : locals.fetch(name)
        }

        block.(*params)
      end

      private

      def with_block(block)
        self.class.new(name, block, to_view: to_view)
      end
    end
  end
end
