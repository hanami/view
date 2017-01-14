require 'dry-equalizer'

module Dry
  module View
    class NullPart < ValuePart
      def [](key)
      end

      def each(&block)
      end

      def respond_to_missing?(*)
        true
      end

      private

      def method_missing(name, *args, &block)
        template_path = template?("#{name}_missing")

        if template_path
          render(template_path, *args, &block)
        else
          nil
        end
      end
    end
  end
end
