require "dry/equalizer"
require_relative "decorated_attributes"

module Dry
  module View
    class Context
      include Dry::Equalizer(:_options)
      include DecoratedAttributes

      attr_reader :_rendering, :_options

      def initialize(rendering: nil, **options)
        @_rendering = rendering
        @_options = options
      end

      def for_rendering(rendering)
        return self if rendering == self._rendering

        self.class.new(**_options.merge(rendering: rendering))
      end

      def with(**new_options)
        self.class.new(rendering: _rendering, **_options.merge(new_options))
      end
    end
  end
end
