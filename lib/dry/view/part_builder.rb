require 'dry/inflector'
require_relative 'part'

module Dry
  module View
    class PartBuilder
      attr_reader :namespace
      attr_reader :inflector

      def initialize(namespace: nil, inflector: Dry::Inflector.new)
        @namespace = namespace
        @inflector = inflector
      end

      def call(name:, value:, renderer:, context:, **options)
        builder = value.respond_to?(:to_ary) ? :build_collection_part : :build_part

        send(builder, name: name, value: value, renderer: renderer, context: context, **options)
      end

      private

      def build_part(name:, value:, renderer:, context:, **options)
        klass = part_class(name: name, **options)

        klass.new(name: name, value: value, part_builder: self, renderer: renderer, context: context)
      end

      def build_collection_part(name:, value:, renderer:, context:, **options)
        collection_as = options[:as].is_a?(Array) ? options[:as].first : nil

        element_name = inflector.singularize(name).to_sym
        element_as =
          if options[:as].is_a?(Array)
            options[:as].last if options[:as].length > 1
          else
            options[:as]
          end

        arr = value.to_ary.map { |obj|
          build_part(name: element_name, value: obj, renderer: renderer, context: context, **options.merge(as: element_as))
        }

        build_part(name: name, value: arr, renderer: renderer, context: context, **options.merge(as: collection_as))
      end

      def part_class(name:, **options)
        name = options[:as] || name

        if name.is_a?(Class)
          name
        else
          resolve_part_class(name: name)
        end
      end

      def resolve_part_class(name:)
        return Part unless namespace

        name = inflector.camelize(name.to_s)

        # Give autoloaders a change to act
        begin
          namespace.const_get(name)
        rescue NameError
        end

        if namespace.const_defined?(name, false)
          namespace.const_get(name)
        else
          Part
        end
      end
    end
  end
end
