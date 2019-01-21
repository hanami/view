module Dry
  class View
    class RenderingMissing
      class MissingRenderingError < StandardError
        def message
          "a +rendering+ must be provided"
        end
      end

      def format
        raise MissingRenderingError
      end

      def part(name, value, **options)
        raise MissingRenderingError
      end

      def scope(name = nil, locals)
        raise MissingRenderingError
      end

      def template(name, scope, &block)
        raise MissingRenderingError
      end

      def partial(name, scope, &block)
        raise MissingRenderingError
      end
    end
  end
end
