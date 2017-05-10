require 'dry/core/inflector'
require 'dry/view/part'

module Dry
  module View
    class Decorator
      attr_reader :config

      # @api public
      def call(name, value, renderer:, context:, **options)
        klass = part_class(name, value, **options)

        if value.respond_to?(:to_ary)
          singular_name = Dry::Core::Inflector.singularize(name).to_sym
          singular_options = singularize_options(options)

          arr = value.to_ary.map { |obj|
            call(singular_name, obj, renderer: renderer, context: context, **singular_options)
          }

          klass.new(name: name, value: arr, renderer: renderer, context: context)
        else
          klass.new(name: name, value: value, renderer: renderer, context: context)
        end
      end

      # @api public
      def part_class(name, value, **options)
        if options[:as].is_a?(Hash)
          options[:as].keys.first
        else
          options.fetch(:as) { Part }
        end
      end

      private

      # @api private
      def singularize_options(**options)
        options[:as] = options[:as].values.first if options[:as].is_a?(Hash)
        options
      end
    end
  end
end
