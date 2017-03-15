require 'dry/view/part'

module Dry
  module View
    # Default decorator, wraps everything in Parts
    class Decorator
      attr_reader :config

      def call(name, object, renderer:, context:, **options)
        if object.respond_to?(:to_ary)
          object.to_ary.map { |obj| Part.new(obj, renderer: renderer, context: context) }
        else
          Part.new(object, renderer: renderer, context: context)
        end
      end
    end
  end
end
