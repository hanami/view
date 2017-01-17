require 'dry-equalizer'

module Dry
  module View
    class Scope
      include Dry::Equalizer(:_renderer, :_data)

      attr_reader :_renderer
      attr_reader :_data

      def initialize(renderer, data = {})
        @_renderer = renderer
        @_data = data
      end

      def respond_to_missing?(name, include_private = false)
        _template?(name) || _data.key?(name)
      end

      private

      def method_missing(name, *args, &block)
        template_path = _template?(name)

        if template_path
          _render(template_path, *args, &block)
        elsif _data.key?(name)
          _data[name]
        else
          super
        end
      end

      def _template?(name)
        _renderer.lookup("_#{name}")
      end

      def _render(path, *args, &block)
        _renderer.render(path, _render_args(*args), &block)
      end

      def _render_args(*args)
        if args.empty?
          self
        elsif args.length == 1 && args.first.respond_to?(:to_hash)
          self.class.new(_renderer, args.first.to_hash)
        else
          raise ArgumentError, "render arguments must be a Hash"
        end
      end
    end
  end
end
