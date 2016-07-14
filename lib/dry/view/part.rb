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
        renderer.render(path, with(scope), &block)
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

      def respond_to_missing?(name, include_private = false)
        template?(name) || super
      end

      private

      def method_missing(name, *args, &block)
        template_path = template?(name)

        if template_path
          render(template_path, prepare_render_scope(name, *args), &block)
        else
          super
        end
      end

      def prepare_render_scope(name, *args)
        if args.none?
          {}
        elsif args.length == 1 && args.first.respond_to?(:to_hash)
          args.first.to_hash
        else
          {name => args.length == 1 ? args.first : args}
        end
      end
    end
  end
end

require 'dry/view/value_part'
