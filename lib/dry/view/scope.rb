require 'dry-equalizer'

module Dry
  module View
    class Scope
      include Dry::Equalizer(:_locals, :_context, :_renderer)

      PartialNotFoundError = Class.new(StandardError)

      attr_reader :_locals
      attr_reader :_context
      attr_reader :_renderer

      def initialize(renderer:, context: nil, locals: {})
        @_locals = locals
        @_context = context
        @_renderer = renderer
      end

      def render(partial_name, **locals, &block)
        path = __partial(partial_name)

        if path
          _renderer.render(
            path,
            __render_scope(locals),
            &block
            )
        else
          msg = "Partial #{partial_name.inspect} could not be found in any path or shared folder"
          raise PartialNotFoundError, msg
        end
      end

      private

      def method_missing(name, *args, &block)
        if _locals.key?(name)
          _locals[name]
        elsif _context.respond_to?(name)
          _context.public_send(name, *args, &block)
        else
          super
        end
      end

      def __partial(name)
        _renderer.lookup("_#{name}")
      end

      def __render_scope(**locals)
        if locals.any?
          self.class.new(renderer: _renderer, context: _context, locals: locals)
        else
          self
        end
      end
    end
  end
end
