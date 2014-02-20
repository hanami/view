require 'lotus/view/rendering/registry'
require 'lotus/view/rendering/scope'

module Lotus
  module View
    module Rendering
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        def initialize(template, locals)
          @template = template
          @scope    = Scope.new(self, locals)
        end

        def render
          layout.render
        end

        protected
        def rendered
          @template.render @scope
        end

        def layout
          @layout ||= self.class.layout.new(@scope, rendered)
        end

        def locals
          @scope.locals
        end

        def method_missing(m)
          @scope.__send__ m
        end
      end

      def render(context, locals)
        registry.resolve(context, locals).render
      end

      protected
      def load!
        super
        registry.freeze
      end

      private
      def registry
        @@registry ||= Registry.new(self)
      end
    end
  end
end
