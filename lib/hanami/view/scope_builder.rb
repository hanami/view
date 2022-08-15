# frozen_string_literal: true

require "dry/core/cache"
require "dry/core/equalizer"
require "dry/effects"
require "dry/inflector"
require_relative "scope"

module Hanami
  class View
    # Builds scope objects via matching classes
    #
    # @api private
    class ScopeBuilder
      extend Dry::Core::Cache
      include Dry::Equalizer(:inflector, :namespace)

      attr_reader :inflector

      # The view's configured `scope_namespace`
      #
      # @api private
      attr_reader :namespace

      # Returns a new instance of ScopeBuilder
      #
      # @api private
      def initialize(inflector: Dry::Inflector.new, namespace: nil)
        @inflector = inflector
        @namespace = namespace
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
        )
      end

      private

      DEFAULT_SCOPE_CLASS = Scope

      def scope_class(name = nil)
        fetch_or_store(:scope_class, namespace, name) {
          if name.nil?
            DEFAULT_SCOPE_CLASS
          elsif name.is_a?(Class)
            name
          else
            resolve_scope_class(name: name)
          end
        }
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
    end
  end
end
