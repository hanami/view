module Dry
  module View
    class Context
      attr_reader :_options, :_part_builder, :_renderer

      def initialize(part_builder: nil, renderer: nil, **options)
        @_part_builder = part_builder
        @_renderer = renderer
        @_options = options
      end

      def bind(part_builder:, renderer:)
        self.class.new(
          **_options.merge(
            part_builder: part_builder,
            renderer: renderer,
          )
        )
      end

      def bound?
        !!(_part_builder && _renderer)
      end

      def self.decorate(*names, **options)
        mod = DecoratedAttributes.new(names) do
          names.each do |name|
            define_method name do
              attribute = super()

              return attribute unless bound? || !attribute

              _part_builder.(
                name: name,
                value: attribute,
                renderer: _renderer,
                context: self,
                **options,
              )
            end
          end
        end

        prepend mod
      end

      class DecoratedAttributes < Module
        def initialize(names, &block)
          @names = names
          super(&block)
        end

        def inspect
          %(#<#{self.class.name}#{@names.inspect}>)
        end
      end
    end
  end
end
