require 'dry/equalizer'
require_relative "decorated_attributes"
require_relative "render_environment_missing"

module Dry
  class View
    class Part
      CONVENIENCE_METHODS = %i[
        format
        context
        render
        scope
        value
      ].freeze

      include Dry::Equalizer(:_name, :_value, :_render_env)
      include DecoratedAttributes

      attr_reader :_name

      attr_reader :_value

      attr_reader :_render_env

      def self.part_name(inflector)
        name ? inflector.underscore(inflector.demodulize(name)) : "part"
      end

      def initialize(render_env: RenderEnvironmentMissing.new, name: self.class.part_name(render_env.inflector), value:)
        @_name = name
        @_value = value
        @_render_env = render_env
      end

      def _format
        _render_env.format
      end

      def _context
        _render_env.context
      end

      def _render(partial_name, as: _name, **locals, &block)
        _render_env.partial(partial_name, _render_env.scope({as => self}.merge(locals)), &block)
      end

      def _scope(scope_name = nil, **locals)
        _render_env.scope(scope_name, {_name => self}.merge(locals))
      end

      def to_s
        _value.to_s
      end

      def new(klass = (self.class), name: (_name), value: (_value), **options)
        klass.new(
          name: name,
          value: value,
          render_env: _render_env,
          **options,
        )
      end

      def inspect
        %(#<#{self.class.name} name=#{_name.inspect} value=#{_value.inspect}>)
      end

      private

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
