module Dry
  module View
    class Exposure
      attr_reader :name
      attr_reader :block

      def initialize(name, block)
        # TODO: raise error if block parameters aren't right

        @name = name
        @block = block
      end

      def bind(obj)
        block ? self : self.class.new(name, obj.method(name))
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
