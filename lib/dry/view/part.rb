require 'dry-equalizer'
require 'inflecto'

module Dry
  module View
    class Part
      def self.build(renderer:, name: nil, value:)
        raise ArgumentError, '+name+ must be provided for a non-Hash +value+' unless name || value.is_a?(Hash)

        case value
        when nil
          NullPart.new(renderer)
        when Array
          el_name = Inflecto.singularize(name).to_sym
          parts = value.map { |el| build(renderer: renderer, name: el_name, value: el) }
          ValuePart.new(renderer, {name => parts})
        else
          data = name ? {name => value} : value
          ValuePart.new(renderer, data)
        end
      end

      include Dry::Equalizer(:renderer)

      attr_reader :renderer

      def initialize(renderer)
        @renderer = renderer
      end

      def render(path, *scope_args, &block)
        renderer.render(path, _with(_render_scope(*scope_args)), &block)
      end

      def template?(name)
        renderer.lookup("_#{name}")
      end

      def respond_to_missing?(name, include_private = false)
        template?(name) || super
      end

      private

      def method_missing(name, *args, &block)
        template_path = template?(name)

        if template_path
          render(template_path, *args, &block)
        else
          super
        end
      end

      def _with(additional_scope)
        self.class.build(renderer: renderer, value: additional_scope)
      end

      def _render_scope(*args)
        if args.empty?
          {}
        elsif args.length == 1 && args.first.respond_to?(:to_hash)
          args.first.to_hash
        else
          raise ArgumentError, "render arguments must be a Hash"
        end
      end
    end
  end
end

require 'dry/view/value_part'
require 'dry/view/null_part'
