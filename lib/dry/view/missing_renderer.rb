module Dry
  module View
    class MissingRendererError < StandardError
      def initialize(message = "No renderer provided")
        super
      end
    end

    class MissingRenderer
      def method_missing(name, *args, &block)
        raise MissingRendererError
      end
    end
  end
end
