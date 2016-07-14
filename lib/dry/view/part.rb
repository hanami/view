require 'dry-equalizer'

module Dry
  module View
    class Part
      include Dry::Equalizer(:renderer)

      attr_reader :renderer

      def initialize(renderer)
        @renderer = renderer
      end

      def render(path, scope = {}, &block)
        renderer.render(path, self.with(scope), &block)
      end

      def template?(name)
        renderer.lookup("_#{name}")
      end

      def with(scope)
        if scope.any?
          ValuePart.new(renderer, scope)
        else
          self
        end
      end

      def respond_to_missing?(meth, include_private = false)
        super || template?(meth)
      end

      private

      def method_missing(meth, *args, &block)
        template_path = template?(meth)

        if template_path
          render(template_path, *args, &block)
        else
          super
        end
      end
    end
  end
end

require 'dry/view/value_part'
