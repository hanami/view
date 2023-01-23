# frozen_string_literal: true

require_relative "scope"

module Hanami
  class View
    # Builds scope objects via matching classes
    #
    # @api private
    class ScopeBuilder
      class << self
        # Returns a new scope using a class matching the name
        #
        # @param name [Symbol, Class] scope name
        # @param locals [Hash<Symbol, Object>] locals hash
        #
        # @return [Hanami::View::Scope]
        #
        # @api private
        def call(name = nil, locals:, rendering:) # rubocop:disable Style/OptionalArguments
          scope_class(name, namespace: rendering.config.scope_namespace, inflector: rendering.inflector)
            .new(name: name, locals: locals, rendering: rendering)
        end

        private

        DEFAULT_SCOPE_CLASS = Scope

        def scope_class(name = nil, namespace:, inflector:)
          if name.nil?
            DEFAULT_SCOPE_CLASS
          elsif name.is_a?(Class)
            name
          else
            View.cache.fetch_or_store(:scope_class, namespace, name) do
            end
            resolve_scope_class(name: name, namespace: namespace, inflector: inflector)
          end
        end

        def resolve_scope_class(name:, namespace:, inflector:)
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
      end
    end
  end
end
