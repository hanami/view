module Dry
  module View
    class Context
      attr_reader :_rendering, :_options

      def initialize(rendering: nil, **options)
        @_rendering = rendering
        @_options = options
      end

      def for_rendering(rendering)
        return self if rendering == self._rendering

        self.class.new(**_options.merge(rendering: rendering))
      end

      def rendering?
        !!_rendering
      end

      def self.decorate(*names, **options)
        mod = DecoratedAttributes.new(names) do
          names.each do |name|
            define_method name do
              attribute = super()

              if rendering? && attribute
                _rendering.part(name, attribute, **options)
              else
                attribute
              end
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
