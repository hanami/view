require 'dry/view/part'

module Dry
  module View
    class Decorator
      attr_reader :config

      def call(name, object, renderer:, context:, **options)
        klass = part_class(name, options)

        if object.respond_to?(:to_ary)
          arr = object.to_ary.map { |obj| klass.new(obj, renderer: renderer, context: context) }
          klass.new(arr, renderer: renderer, context: context)
        else
          klass.new(object, renderer: renderer, context: context)
        end
      end

      def part_class(name, options)
        options.fetch(:as) { Part }
      end
    end
  end
end
