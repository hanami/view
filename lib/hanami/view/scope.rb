# frozen_string_literal: true

require "dry/equalizer"
require "dry/core/constants"
require_relative "render_environment_missing"

module Hanami
  class View
    # Evaluation context for templates (including layouts and partials) and
    # provides a place to encapsulate view-specific behaviour alongside a
    # template and its locals.
    #
    # @abstract Subclass this and provide your own methods adding view-specific
    #   behavior. You should not override `#initialize`
    #
    # @see https://dry-rb.org/gems/dry-view/templates/
    # @see https://dry-rb.org/gems/dry-view/scopes/
    #
    # @api public
    class Scope
      # @api private
      CONVENIENCE_METHODS = %i[format context locals].freeze

      include Dry::Equalizer(:_name, :_locals, :_render_env)

      # The scope's name
      #
      # @return [Symbol]
      #
      # @api public
      attr_reader :_name

      # The scope's locals
      #
      # @overload _locals
      #   Returns the locals
      # @overload locals
      #   A convenience alias for `#_format.` Is available unless there is a
      #   local named `locals`
      #
      # @return [Hash[<Symbol, Object>]
      #
      # @api public
      attr_reader :_locals

      # The current render environment
      #
      # @return [RenderEnvironment] render environment
      #
      # @api private
      attr_reader :_render_env

      # Returns a new Scope instance
      #
      # @param name [Symbol, nil] scope name
      # @param locals [Hash<Symbol, Object>] template locals
      # @param render_env [RenderEnvironment] render environment
      #
      # @return [Scope]
      #
      # @api public
      def initialize(
        name: nil,
        locals: Dry::Core::Constants::EMPTY_HASH,
        render_env: RenderEnvironmentMissing.new
      )
        @_name = name
        @_locals = locals
        @_render_env = render_env
      end

      # @overload render(partial_name, **locals, &block)
      #   Renders a partial using the scope
      #
      #   @param partial_name [Symbol, String] partial name
      #   @param locals [Hash<Symbol, Object>] partial locals
      #   @yieldreturn [String] string content to include where the partial calls `yield`
      #
      # @overload render(**locals, &block)
      #   Renders a partial (named after the scope's own name) using the scope
      #
      #   @param locals[Hash<Symbol, Object>] partial locals
      #   @yieldreturn [String] string content to include where the partial calls `yield`
      #
      # @return [String] the rendered partial output
      #
      # @api public
      def render(partial_name = nil, **locals, &block)
        partial_name ||= _name

        unless partial_name
          raise ArgumentError, "+partial_name+ must be provided for unnamed scopes"
        end

        if partial_name.is_a?(Class)
          partial_name = _inflector.underscore(_inflector.demodulize(partial_name.to_s))
        end

        _render_env.partial(partial_name, _render_scope(**locals), &block)
      end

      # Build a new scope using a scope class matching the provided name
      #
      # @param name [Symbol, Class] scope name (or class)
      # @param locals [Hash<Symbol, Object>] scope locals
      #
      # @return [Scope]
      #
      # @api public
      def scope(name = nil, **locals)
        _render_env.scope(name, locals)
      end

      # The template format for the current render environment.
      #
      # @overload _format
      #   Returns the format.
      # @overload format
      #   A convenience alias for `#_format.` Is available unless there is a
      #   local named `format`
      #
      # @return [Symbol] format
      #
      # @api public
      def _format
        _render_env.format
      end

      # The context object for the current render environment
      #
      # @overload _context
      #   Returns the context.
      # @overload context
      #   A convenience alias for `#_context`. Is available unless there is a
      #   local named `context`.
      #
      # @return [Context] context
      #
      # @api public
      def _context
        _render_env.context
      end

      private

      # Handles missing methods, according to the following rules:
      #
      # 1. If there is a local with a name matching the method, it returns the
      #    local.
      # 2. If the `context` responds to the method, then it will be sent the
      #    method and all its arguments.
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
      ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)

      def respond_to_missing?(name, include_private = false)
        _locals.key?(name) ||
          _render_env.context.respond_to?(name) ||
          CONVENIENCE_METHODS.include?(name) ||
          super
      end

      def _render_scope(**locals)
        if locals.none?
          self
        else
          self.class.new(
            # FIXME: what about `name`?
            locals: locals,
            render_env: _render_env
          )
        end
      end

      def _inflector
        _render_env.inflector
      end
    end
  end
end
