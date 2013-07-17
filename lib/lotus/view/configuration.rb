module Lotus
  module View
    module Configuration
      def root=(root)
        @root = Pathname.new(root)
      end

      def root
        @root ||= Lotus::View.root
      end

      def engine=(engine)
        @engine = engine
      end

      def engine
        @engine ||= Lotus::View.engine
      end
    end
  end
end
