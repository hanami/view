require 'dry/equalizer'
require 'dry/core/constants'
require_relative "render_environment_missing"

module Dry
  class View
    class Scope
      CONVENIENCE_METHODS = %i[format context locals].freeze

      include Dry::Equalizer(:_name, :_locals, :_render_env)

      attr_reader :_name
      attr_reader :_locals
      attr_reader :_render_env

      def initialize(name: nil, locals: Dry::Core::Constants::EMPTY_HASH, render_env: RenderEnvironmentMissing.new)
        @_name = name
        @_locals = locals
        @_render_env = render_env
      end

      def render(partial_name = nil, **locals, &block)
        partial_name ||= _name
        raise ArgumentError, "+partial_name+ must be provided for unnamed scopes" unless partial_name
        partial_name = _inflector.underscore(_inflector.demodulize(partial_name.to_s)) if partial_name.is_a?(Class)

        _render_env.partial(partial_name, _render_scope(locals), &block)
      end

      def scope(name = nil, **locals)
        _render_env.scope(name, locals)
      end

      def _format
        _render_env.format
      end

      def _context
        _render_env.context
      end

      private

      def method_missing(name, *args, &block)
        if _locals.key?(name)
          _locals[name]
        elsif _context.respond_to?(name)
          _context.public_send(name, *args, &block)
        elsif CONVENIENCE_METHODS.include?(name)
          __send__(:"_#{name}", *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        _locals.key?(name) || _render_env.context.respond_to?(name) || CONVENIENCE_METHODS.include?(name) || super
      end

      def _render_scope(**locals)
        if locals.none?
          self
        else
          self.class.new(
            # FIXME: what about `name`?
            locals: locals,
            render_env: _render_env,
          )
        end
      end

      def _inflector
        _render_env.inflector
      end
    end
  end
end
