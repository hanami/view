require 'lotus/view/rendering/context'
require 'lotus/view/rendering/registry'

module Lotus
  module View
    module Rendering
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      def render(context, locals)
        registry.resolve(Context.new(context)).render(locals)
      end

      module InstanceMethods
        def render(locals)
          @template.render(nil, locals)
        end
      end

      private
      def load!
        super
        registry
        nil
      end

      def registry
        @registry ||= Registry.new(self)
      end
    end
  end
end
