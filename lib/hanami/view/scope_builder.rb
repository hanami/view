# frozen_string_literal: true

require "dry/core/cache"
require "dry/equalizer"
require_relative "scope"

module Hanami
  class View
    # Builds scope objects via matching classes
    #
    # @api private
    class ScopeBuilder
      extend Dry::Core::Cache
      include Dry::Equalizer(:namespace)

      # The view's configured `scope_namespace`
      #
      # @api private
      attr_reader :namespace

      # @return [RenderEnvironment]
      #
      # @api private
      attr_reader :render_env

      # Returns a new instance of ScopeBuilder
      #
      # @api private
      def initialize(namespace: nil, render_env: nil)
        @namespace = namespace
        @render_env = render_env
      end

      # @api private
      def for_render_env(render_env)
        return self if render_env == self.render_env

        self.class.new(namespace: namespace, render_env: render_env)
      end

      # Returns a new scope using a class matching the name
      #
      # @param name [Symbol, Class] scope name
      # @param locals [Hash<Symbol, Object>] locals hash
      #
      # @return [Hanami::View::Scope]
      #
      # @api private
      def call(name = nil, locals) # rubocop:disable Style/OptionalArguments
        scope_class(name).new(
          name: name,
          locals: locals,
          render_env: render_env
        )
      end

      private

      DEFAULT_SCOPE_CLASS = Scope

      def scope_class(name = nil)
        if name.nil?
          DEFAULT_SCOPE_CLASS
        elsif name.is_a?(Class)
          name
        else
          fetch_or_store(namespace, name) do
            resolve_scope_class(name: name)
          end
        end
      end

      def resolve_scope_class(name:)
        name = inflector.camelize(name.to_s)

        # Give autoloaders a chance to act
        begin
          klass = namespace.const_get(name)
        rescue NameError # rubocop:disable Lint/HandleExceptions
        end

        if !klass && namespace.const_defined?(name, false)
          klass = namespace.const_get(name)
        end

        if klass && klass < Scope
          klass
        else
          DEFAULT_SCOPE_CLASS
        end
      end

      def inflector
        render_env.inflector
      end
    end
  end
end
