require 'dry-equalizer'

module Dry
  module View
    class Part
      CONVENIENCE_METHODS = %i[
        context
        render
        scope
        value
      ].freeze

      include Dry::Equalizer(:_name, :_value, :_rendering)

      attr_reader :_name

      attr_reader :_value

      attr_reader :_rendering

      attr_reader :_decorated_attributes

      # @api public
      def self.decorate(*names, **options)
        names.each do |name|
          decorated_attributes[name] = options
        end
      end

      # @api private
      def self.decorated_attributes
        @decorated_attributes ||= {}
      end

      def initialize(name:, value:, rendering:)
        @_name = name
        @_value = value
        @_rendering = rendering

        @_decorated_attributes = {}
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
        if self.class.decorated_attributes.key?(name)
          _resolve_decorated_attribute(name)
        elsif _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif CONVENIENCE_METHODS.include?(name)
          __send__(:"_#{name}", *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        d = self.class.decorated_attributes
        c = CONVENIENCE_METHODS
        d.key?(name) || c.include?(name) || _value.respond_to?(name, include_private) || super
      end

      def _resolve_decorated_attribute(name)
        _decorated_attributes.fetch(name) {
          attribute = _value.__send__(name)

          _decorated_attributes[name] =
            if attribute
              # Decorate truthy attributes only
              _rendering.part(name, attribute, **self.class.decorated_attributes[name])
            end
        }
      end
    end
  end
end
