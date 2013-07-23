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
        view, template = registry.resolve(Context.new(context))
        view.new(template, locals).render
      end

      module InstanceMethods
        def render
          @template.render(self, @locals)
        end

        protected
        # TODO find an elegant way to achieve this
        def method_missing(name, *args, &blk)
          if @locals.key?(name)
            @locals[name]
          else
            super
          end
        end
      end

      private
      def load!
        super
        registry
        nil
      end

      def registry
        @registry ||= Registry.new(self, Lotus::View.formats)
      end
    end
  end
end
