require 'dry-equalizer'
require 'dry/view/value_part'

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

      def method_missing(meth, *args, &block)
        template_path = template?("#{meth}_missing")

        if template_path
          render(template_path)
        else
          nil
        end
      end
    end
  end
end
