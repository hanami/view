require 'dry-equalizer'

# This is looking pretty good. Could even just have a plain view part as the main view scope.

module Dry
  module View
    class Part
      include Dry::Equalizer(:_object, :_renderer, :_context, :_locals)

      attr_reader :_object
      attr_reader :_renderer
      attr_reader :_context
      attr_reader :_locals

      def initialize(object = nil, renderer:, context: nil, locals: {})
        @_object = object
        @_renderer = renderer
        @_context = context
        @_locals = locals
      end

      def __render(partial_name, object = _object, **locals, &block)
        _renderer.render(__partial(partial_name), __render_scope(object, **locals), &block)
      end
      alias_method :render, :__render

      def to_s
        _object.to_s
      end

      # TODO: nicer, custom inspect
      # def inspect
      # end

      private

      def method_missing(name, *args, &block)
        if _locals.key?(name)
          _locals[name]
        elsif _object.respond_to?(name)
          _object.public_send(name, *args, &block)
        elsif _object.is_a?(Hash) && _object.key?(name)
          _object[name]
        elsif _context.respond_to?(name)
          _context.public_send(name, *args, &block)
        else
          super
        end
      end

      def __partial(name)
        _renderer.lookup("_#{name}")
      end

      def __render_scope(object, **locals)
        return self if object == _object && (locals == _locals || locals.empty?)

        self.class.new(
          object,
          renderer: _renderer,
          context: _context,
          locals: locals,
        )
      end
    end
  end
end
