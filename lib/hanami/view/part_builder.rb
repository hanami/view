# frozen_string_literal: true

require "dry/core/equalizer"
require_relative "part"

module Hanami
  class View
    # Decorates exposure values with matching parts
    #
    # @api private
    class PartBuilder
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
      # @param as [Symbol, nil] alternative name to use for part class resolution
      #
      # @return [Hanami::View::Part] decorated value
      #
      # @api private
      def call(name, value, as: nil)
        builder = value.respond_to?(:to_ary) ? :build_collection_part : :build_part

        send(builder, name, value, as: as)
      end

      private

      def build_part(name, value, as:)
        klass = part_class(name: name, as: as)

        klass.new(
          name: name,
          value: value,
          render_env: render_env
        )
      end

      def build_collection_part(name, value, as: nil)
        item_name, item_as = collection_item_name_as(name: name, as: as)
        item_part_class = part_class(name: item_name, as: item_as)

        arr = value.to_ary.map { |item|
          item_part_class.new(name: item_name, value: item, render_env: render_env)
        }

        collection_as = as.is_a?(Array) ? as.first : nil
        build_part(name, arr, as: collection_as)
      end

      def collection_item_name_as(name:, as:)
        singular_name = inflector.singularize(name).to_sym
        singular_as =
          if as.is_a?(Array)
            as.last if as.length > 1
          else
            as
          end

        if singular_as && !singular_as.is_a?(Class)
          singular_as = inflector.singularize(singular_as.to_s)
        end

        [singular_name, singular_as]
      end

      def part_class(name:, as:, fallback_class: Part)
        name = as || name

        if name.is_a?(Class)
          name
        else
          render_env.cache.fetch_or_store([:part_class, namespace, name, fallback_class].hash) do
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
