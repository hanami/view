require 'dry/inflector'
require_relative 'scope'

module Dry
  module View
    class ScopeBuilder
      attr_reader :namespace
      attr_reader :inflector

      def initialize(namespace: nil, inflector: Dry::Inflector.new)
        @namespace = namespace
        @inflector = inflector
      end

      def call(name: nil, locals:, context:, renderer:)
        scope_class(name: name).new(
          name: name,
          locals: locals,
          context: context,
          renderer: renderer,
          scope_builder: self,
        )
      end

      private

      DEFAULT_SCOPE_CLASS = Scope

      def scope_class(name: nil)
        if name.nil?
          DEFAULT_SCOPE_CLASS
        elsif name.is_a?(Class)
          name
        else
          resolve_scope_class(name: name)
        end
      end

      def resolve_scope_class(name:)
        return fallback_class unless namespace

        name = inflector.camelize(name.to_s)

        # Give autoloaders a change to act
        begin
          klass = namespace.const_get(name)
        rescue NameError
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
