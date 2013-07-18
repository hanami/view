require 'lotus/view/rendering/resolver'

module Lotus
  module View
    module Rendering
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        def render(context)
          _template_for(context).render(nil, context)
        end

        private
        def template_resolver
          self.class.template_resolver
        end

        def _template_for(context)
          template_resolver.resolve(context)
        end
      end

      def template_resolver
        @@template_resolver ||= Resolver.new(self)
      end

      private
      def load!
        super
        template_resolver
        nil
      end
    end
  end
end
