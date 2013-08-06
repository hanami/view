require 'lotus/view/rendering/layout_registry'
require 'lotus/view/rendering/layout_scope'
require 'lotus/view/rendering/null_layout'

module Lotus
  module View
    module Layout
      def self.included(base)
        base.class_eval do
          extend Lotus::View::Dsl.dup
          extend ClassMethods
        end

        Lotus::View.layouts.add(base)
      end

      module ClassMethods
        SUFFIX = '_layout'.freeze

        def registry
          @@registry ||= Rendering::LayoutRegistry.new(self)
        end

        def template
          super.gsub(suffix, '')
        end

        def suffix
          SUFFIX
        end

        protected
        def load!
          registry.freeze
        end
      end

      def initialize(scope, rendered)
        @scope, @rendered = Rendering::LayoutScope.new(self, scope), rendered
      end

      def render
        template.render(@scope, &Proc.new{@rendered})
      end

      protected
      def template
        self.class.registry.resolve({format: @scope.format})
      end
    end
  end
end
