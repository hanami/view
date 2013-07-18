module Lotus
  module View
    module Dsl
      def root(value = nil)
        if value
          @root = Pathname.new(value)
        else
          @root ||= Lotus::View.root
        end
      end

      def format(format)
        formats.add(format)
      end

      def formats
        @formats ||= Lotus::View.formats
      end
    end
  end
end
