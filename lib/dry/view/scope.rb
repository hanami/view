module Dry
  module View
    class Scope
      attr_reader :_renderer
      attr_reader :_scope

      def initialize(renderer, scope = {})
        @_renderer = renderer
        @_scope = scope
      end

      def render(path, *args, &block)
        _renderer.render(path, _render_args(*args), &block)
      end

      def respond_to_missing?(name, include_private = false)
        _template?(name) || _scope.key?(name)
      end

      private

      def method_missing(name, *args, &block)
        template_path = _template?(name)

        if template_path
          render(template_path, *args, &block)
        elsif _scope.key?(name)
          _scope[name]
        else
          super
        end
      end

      def _template?(name)
        _renderer.lookup("_#{name}")
      end

      def _render_args(*args)
        if args.empty?
          self
        elsif args.length == 1 && args.first.respond_to?(:to_hash)
          self.class.new(_renderer, args.first.to_hash)
        else
          raise ArgumentError, "render arguments must be a Hash"
        end
      end
    end
  end
end
