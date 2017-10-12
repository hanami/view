module Dry
  module View
    class MissingRenderer

      MissingRendererError = Class.new(StandardError)

      def method_missing(name, *args, &block)
        raise MissingRendererError, "No renderer provided"
      end
    end
  end
end
