require 'dry/equalizer'
require_relative 'scope'

module Dry
  module View
    class ScopeBuilder
      include Dry::Equalizer(:namespace)

      attr_reader :namespace
      attr_reader :rendering

      def initialize(namespace: nil, rendering: nil)
        @namespace = namespace
        @rendering = rendering
      end

      def for_rendering(rendering)
        return self if rendering == self.rendering

        self.class.new(namespace: namespace, rendering: rendering)
      end

      def rendering?
        !!rendering
      end

      def call(name = nil, locals)
        scope_class(name).new(
          name: name,
          locals: locals,
          rendering: rendering,
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
          resolve_scope_class(name: name)
        end
      end

      def resolve_scope_class(name:)
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

      def inflector
        rendering.inflector
      end
    end
  end
end
