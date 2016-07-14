require 'dry-equalizer'
require 'dry/view/value_part'

module Dry
  module View
    class NullPart < ValuePart
      def [](key)
      end

      def each(&block)
      end

      def with(scope)
        if scope.any?
          ValuePart.new(renderer, _data.merge(scope))
        else
          self
        end
      end

      def respond_to_missing?(*)
        true
      end

      private

      def method_missing(meth, *args, &block)
        template_path = template?("#{meth}_missing")

        if template_path
          render(template_path, *args, &block)
        else
          nil
        end
      end
    end
  end
end
