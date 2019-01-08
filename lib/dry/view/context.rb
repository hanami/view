require "dry/equalizer"
require "set"

module Dry
  module View
    class Context
      DECORATED_ATTRIBUTES = :DecoratedAttributes

      def self.decorate(*names, **options)
        decorated_attributes.decorate(*names, **options)
      end

      def self.decorated_attributes
        if const_defined?(DECORATED_ATTRIBUTES, false)
          const_get(DECORATED_ATTRIBUTES)
        else
          const_set(DECORATED_ATTRIBUTES, DecoratedAttributes.new).tap do |mod|
            prepend mod
          end
        end
      end
      private_class_method :decorated_attributes

      include Dry::Equalizer(:_options)

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

      def with(**new_options)
        self.class.new(rendering: _rendering, **_options.merge(new_options))
      end

      class DecoratedAttributes < Module
        def initialize(*)
          @names = Set.new
          super
        end

        def decorate(*names, **options)
          @names += names

          class_eval do
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
        end

        def inspect
          %(#<#{self.class.name}#{@names.to_a.sort.inspect}>)
        end
      end
    end
  end
end
