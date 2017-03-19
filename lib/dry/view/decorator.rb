require 'dry/view/part'

module Dry
  module View
    class Decorator
      attr_reader :config

      def call(name, object, renderer:, context:, **options)
        if object.respond_to?(:to_ary)
          object.to_ary.map { |obj| part_class(name, options).new(obj, renderer: renderer, context: context) }
        else
          part_class(name, options).new(object, renderer: renderer, context: context)
        end
      end

      def part_class(name, options)
        options.fetch(:as) { Part }
      end
    end
  end
end
