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
      def self.decorate(name, **options)
        decorated_attributes[name] = options
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

        @_decorated_attributes = self.class.decorated_attributes.each_with_object({}) { |(attr_name, options), attrs|
          attrs[attr_name] = decorator.(
            attr_name,
            value.__send__(attr_name),
            renderer: _renderer,
            context: _context,
            **options,
          )
        }
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
        if _decorated_attributes.key?(name)
          _decorated_attributes[name]
        elsif _value.respond_to?(name)
          _value.public_send(name, *args, &block)
        elsif CONVENIENCE_METHODS.include?(name)
          __send__(:"_#{name}", *args, &block)
        else
          super
        end
      end

      def _render_scope(name, **locals)
        Scope.new(
          locals: locals.merge(name => self),
          context: _context,
          renderer: _renderer,
        )
      end
    end
  end
end
