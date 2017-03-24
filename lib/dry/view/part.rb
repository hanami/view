require 'dry-equalizer'

module Dry
  module View
    class Part
      include Dry::Equalizer(:_value, :_locals, :_context, :_renderer)

      attr_reader :_value
      attr_reader :_locals
      attr_reader :_context
      attr_reader :_renderer

      def initialize(value = nil, renderer:, context: nil, locals: {})
        @_value = value
        @_locals = locals
        @_context = context
        @_renderer = renderer
      end

      def __render(partial_name, value = _value, **locals, &block)
        _renderer.render(__partial(partial_name), __render_scope(value, **locals), &block)
      end
      alias_method :render, :__render

      def to_s
        _value.to_s
      end

      private

      def method_missing(name, *args, &block)
        if _locals.key?(name)
          _locals[name]
        elsif _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif _value.is_a?(Hash) && _value.key?(name)
          _value[name]
        elsif _context.respond_to?(name)
          _context.public_send(name, *args, &block)
        else
          super
        end
      end

      def __partial(name)
        _renderer.lookup("_#{name}")
      end

      def __render_scope(value, **locals)
        return self if value == _value && (locals == _locals || locals.empty?)

        # Don't rewrap existing parts
        value = value._value if value.is_a?(Part)

        self.class.new(
          value,
          renderer: _renderer,
          context: _context,
          locals: locals,
        )
      end
    end
  end
end
