require 'dry/equalizer'
require 'dry/core/constants'

module Dry
  module View
    class Scope
      include Dry::Equalizer(:_name, :_locals, :_context, :_renderer, :_scope_builder)

      attr_reader :_name
      attr_reader :_locals
      attr_reader :_context
      attr_reader :_renderer
      attr_reader :_scope_builder

      def initialize(name: nil, locals: Dry::Core::Constants::EMPTY_HASH, context: nil, renderer:, scope_builder:)
        @_name = name
        @_locals = locals
        @_context = context
        @_renderer = renderer
        @_scope_builder = scope_builder
      end

      def render(partial_name = nil, **locals, &block)
        partial_name ||= _name

        raise ArgumentError, "+partial_name+ must be provided for unnamed scopes" unless partial_name

        _renderer.partial(partial_name, _render_scope(locals), &block)
      end

      def scope(name = nil, **locals)
        _scope_builder.(
          name: name,
          locals: locals,
          context: _context,
          renderer: _renderer,
        )
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

      def _render_scope(**locals)
        if locals.none?
          self
        else
          self.class.new(
            locals: locals,
            context: _context,
            renderer: _renderer,
            scope_builder: _scope_builder,
          )
        end
      end
    end
  end
end
