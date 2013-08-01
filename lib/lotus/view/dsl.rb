module Lotus
  module View
    module Dsl
      def root(value = nil)
        if value
          @@root = Pathname.new value
        else
          @@root ||= Lotus::View.root
        end
      end

      def format(value = nil)
        if value
          @format = value
        else
          @format
        end
      end

      protected
      def load!
        super
        root.freeze
        format.freeze
      end
    end
  end
end
