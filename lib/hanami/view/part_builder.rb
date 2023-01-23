# frozen_string_literal: true

require_relative "part"

module Hanami
  class View
    # Decorates exposure values with matching parts
    #
    # @api private
    class PartBuilder
      class << self
        # Decorates an exposure value
        #
        # @param name [Symbol] exposure name
        # @param value [Object] exposure value
        # @param as [Symbol, nil] alternative name to use for part class resolution
        #
        # @return [Hanami::View::Part] decorated value
        #
        # @api private
        def call(name, value, as: nil, rendering:)
          builder = value.respond_to?(:to_ary) ? :build_collection_part : :build_part

          send(builder, name: name, value: value, as: as, rendering: rendering)
        end

        private

        def build_part(name:, value:, as:, rendering:)
          klass = part_class(name: name, as: as, namespace: rendering.config.part_namespace, inflector: rendering.inflector)

          klass.new(name: name, value: value, rendering: rendering)
        end

        def build_collection_part(name:, value:, as: nil, rendering:)
          item_name, item_as = collection_item_name_as(name, as, inflector: rendering.inflector)
          item_part_class = part_class(name: item_name, as: item_as, namespace: rendering.config.part_namespace, inflector: rendering.inflector)

          arr = value.to_ary.map { |item|
            item_part_class.new(name: item_name, value: item, rendering: rendering)
          }

          collection_as = as.is_a?(Array) ? as.first : nil
          build_part(name: name, value: arr, as: collection_as, rendering: rendering)
        end

        def collection_item_name_as(name, as, inflector:)
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

        def part_class(name:, as:, namespace:, inflector:, fallback_class: Part)
          name = as || name

          if name.is_a?(Class)
            name
          else
            View.cache.fetch_or_store(:part_class, namespace, name, fallback_class) do
              resolve_part_class(name: name, namespace: namespace, inflector: inflector, fallback_class: fallback_class)
            end
          end
        end

        # rubocop:disable Metrics/PerceivedComplexity
        def resolve_part_class(name:, namespace:, inflector:, fallback_class:)
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
      end
    end
  end
end
