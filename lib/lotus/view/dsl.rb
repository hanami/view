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
        ancestor.remove_format(@format = format)
      end

      def formats
        @formats ||= begin
          if @format
            Set.new([@format])
          else
            Lotus::View.formats
          end
        end
      end

      protected
      def remove_format(format)
        formats.delete(format)
      end

      private
      def load!
        super
        formats
        nil
      end
    end
  end
end
