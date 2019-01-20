require 'dry-equalizer'
require_relative "decorated_attributes"

module Dry
  class View
    class Part
      CONVENIENCE_METHODS = %i[
        context
        render
        scope
        value
      ].freeze

      include Dry::Equalizer(:_name, :_value, :_rendering)
      include DecoratedAttributes

      attr_reader :_name

      attr_reader :_value

      attr_reader :_rendering

      def initialize(name:, value:, rendering:)
        @_name = name
        @_value = value
        @_rendering = rendering
      end

      def _render(partial_name, as: _name, **locals, &block)
        _rendering.partial(partial_name, _rendering.scope({as => self}.merge(locals)), &block)
      end

      def _scope(scope_name = nil, **locals)
        _rendering.scope(scope_name, {_name => self}.merge(locals))
      end

      def to_s
        _value.to_s
      end

      def new(klass = (self.class), name: (_name), value: (_value), **options)
        klass.new(
          name: name,
          value: value,
          rendering: _rendering,
          **options,
        )
      end

      def inspect
        %(#<#{self.class.name} name=#{_name.inspect} value=#{_value.inspect}>)
      end

      private

      def _context
        _rendering.context
      end

      def method_missing(name, *args, &block)
        if _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif CONVENIENCE_METHODS.include?(name)
          __send__(:"_#{name}", *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        CONVENIENCE_METHODS.include?(name) || _value.respond_to?(name, include_private) || super
      end
    end
  end
end
