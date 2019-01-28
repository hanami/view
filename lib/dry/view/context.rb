require "dry/equalizer"
require_relative "decorated_attributes"

module Dry
  class View
    class Context
      include Dry::Equalizer(:_options)
      include DecoratedAttributes

      attr_reader :_render_env, :_options

      def initialize(render_env: nil, **options)
        @_render_env = render_env
        @_options = options
      end

      def for_render_env(render_env)
        return self if render_env == self._render_env

        self.class.new(**_options.merge(render_env: render_env))
      end

      def with(**new_options)
        self.class.new(
          render_env: _render_env,
          **_options.merge(new_options),
        )
      end
    end
  end
end
