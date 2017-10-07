module Dry
  module View
    class DefaultRenderer
      def method_missing(name, *args, &block)
        raise "No renderer provided"
      end
    end
  end
end
