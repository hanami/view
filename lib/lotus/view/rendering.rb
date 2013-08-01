require 'lotus/view/rendering/registry'

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
          @template, @locals = template, locals
        end

        def render
          template.render(self, @locals)
        end

        protected
        def method_missing(name, *args, &blk)
          if @locals.key?(name)
            @locals[name]
          else
            super
          end
        end

        private
        attr_reader :template
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
