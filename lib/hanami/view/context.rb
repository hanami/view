# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/effects"
require_relative "decorated_attributes"

module Hanami
  class View
    # Provides a baseline environment across all the templates, parts and scopes
    # in a given rendering.
    #
    # @abstract Subclass this and add your own methods (along with a custom
    #   `#initialize` if you wish to inject dependencies)
    #
    # @api public
    class Context
      include Dry::Effects.Reader(:render_env)
      include Dry::Effects.Reader(:scope)
      include DecoratedAttributes

      def locals
        scope._locals
      end
    end
  end
end
