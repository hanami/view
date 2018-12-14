require 'dry/inflector'
require_relative 'part'

module Dry
  module View
    class PartBuilder
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

      def call(name, value, **options)
        builder = value.respond_to?(:to_ary) ? :build_collection_part : :build_part

        send(builder, name, value, **options)
      end

      private

      def build_part(name, value, **options)
        klass = part_class(name: name, **options)

        klass.new(
          name: name,
          value: value,
          rendering: rendering,
        )
      end

      def build_collection_part(name, value, **options)
        collection_as = collection_options(name: name, **options)[:as]
        item_name, item_as = collection_item_options(name: name, **options).values_at(:name, :as)

        arr = value.to_ary.map { |obj|
          build_part(item_name, obj, **options.merge(as: item_as))
        }

        build_part(name, arr, **options.merge(as: collection_as))
      end

      def collection_options(name:, **options)
        collection_as = options[:as].is_a?(Array) ? options[:as].first : nil

        options.merge(as: collection_as)
      end

      def collection_item_options(name:, **options)
        singular_name = inflector.singularize(name).to_sym
        singular_as =
          if options[:as].is_a?(Array)
            options[:as].last if options[:as].length > 1
          else
            options[:as]
          end

        if singular_as && !singular_as.is_a?(Class)
          singular_as = inflector.singularize(singular_as.to_s)
        end

        options.merge(
          name: singular_name,
          as: singular_as,
        )
      end

      def part_class(name:, fallback_class: Part, **options)
        name = options[:as] || name

        if name.is_a?(Class)
          name
        else
          resolve_part_class(name: name, fallback_class: fallback_class)
        end
      end

      def resolve_part_class(name:, fallback_class:)
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

        if klass && klass < Part
          klass
        else
          fallback_class
        end
      end

      def inflector
        rendering.inflector
      end
    end
  end
end
