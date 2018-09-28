require 'dry-equalizer'
require 'dry/view/scope'
require 'dry/view/missing_renderer'

module Dry
  module View
    class Part
      CONVENIENCE_METHODS = %i[
        context
        render
        value
      ].freeze

      include Dry::Equalizer(:_name, :_value, :_decorator, :_context, :_renderer)

      attr_reader :_name

      attr_reader :_value

      attr_reader :_context

      attr_reader :_renderer

      attr_reader :_decorator

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

      # FIXME: does MissingRenderer.new lead to needless allocations of MissingRenderer? We only need one globally.
      def initialize(name:, value:, decorator: Dry::View::Decorator.new, renderer: MissingRenderer.new, context: nil)
        @_name = name
        @_value = value
        @_context = context
        @_renderer = renderer
        @_decorator = decorator
        @_decorated_attributes = {}
      end

      def _render(partial_name, as: _name, **locals, &block)
        _renderer.partial(partial_name, _render_scope(as, locals), &block)
      end

      def to_s
        _value.to_s
      end

      def new(klass = (self.class), name: (_name), value: (_value), **options)
        klass.new(
          name: name,
          value: value,
          context: _context,
          renderer: _renderer,
          decorator: _decorator,
          **options,
        )
      end

      private

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

      def _render_scope(name, **locals)
        Scope.new(
          locals: locals.merge(name => self),
          context: _context,
          renderer: _renderer,
        )
      end

      def _resolve_decorated_attribute(name)
        _decorated_attributes.fetch(name) {
          attribute = _value.__send__(name)

          _decorated_attributes[name] =
            if attribute # Decorate truthy attributes only
              _decorator.(
                name,
                attribute,
                renderer: _renderer,
                context: _context,
                **self.class.decorated_attributes[name],
              )
            end
        }
      end
    end
  end
end
