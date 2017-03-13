require 'dry/view/part'

module Dry
  module View
    # Basic default decorator, just wraps everything in Parts. TODO: pass the
    # name of each exposure through so we can support more advanced behaviours,
    # choosing part classes based on name, etc.
    class Decorator
      attr_reader :config

      # I wonder if we should extract a "Render" class bundling up the renderer
      # and context etc. for a particular `#call` to a view controller...
      def call(object, renderer, context)
        if object.respond_to?(:to_ary)
          object.to_ary.map { |obj| Part.new(obj, renderer: renderer, context: context) }
        else
          Part.new(object, renderer: renderer, context: context)
        end
      end
    end
  end
end
