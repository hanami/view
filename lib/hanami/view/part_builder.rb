# frozen_string_literal: true

require "dry/core/cache"
require "dry/equalizer"
require_relative "part"

module Hanami
  class View
    # Decorates exposure values with matching parts
    #
    # @api private
    class PartBuilder
      extend Dry::Core::Cache
      include Dry::Equalizer(:namespace)

      attr_reader :namespace
      attr_reader :render_env

      # Returns a new instance of PartBuilder
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

      # Decorates an exposure value
      #
      # @param name [Symbol] exposure name
      # @param value [Object] exposure value
      # @param options [Hash] exposure options
      #
      # @return [Hanami::View::Part] decorated value
      #
      # @api private
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
          render_env: render_env
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

      # rubocop:disable Lint/UnusedMethodArgument
      def collection_options(name:, **options)
        collection_as = options[:as].is_a?(Array) ? options[:as].first : nil

        options.merge(as: collection_as)
      end
      # rubocop:enable Lint/UnusedMethodArgument

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
          as: singular_as
        )
      end

      def part_class(name:, fallback_class: Part, **options)
        name = options[:as] || name

        if name.is_a?(Class)
          name
        else
          fetch_or_store(namespace, name, fallback_class) do
            resolve_part_class(name: name, fallback_class: fallback_class)
          end
        end
      end

      # rubocop:disable Metrics/PerceivedComplexity
      def resolve_part_class(name:, fallback_class:)
        return fallback_class unless namespace

        name = inflector.camelize(name.to_s)

        # Give autoloaders a chance to act
        begin
          klass = namespace.const_get(name)
        rescue NameError # rubocop:disable Lint/HandleExceptions
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
      # rubocop:enable Metrics/PerceivedComplexity

      def inflector
        render_env.inflector
      end
    end
  end
end
