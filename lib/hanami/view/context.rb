# frozen_string_literal: true

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
      include DecoratedAttributes

      attr_reader :_rendering, :_options

      # Returns a new instance of Context
      #
      # In subclasses, you should include an `**options` parameter and pass _all
      # arguments_ to `super`. This allows Context to make copies of itself
      # while preserving your dependencies.
      #
      # @example
      #   class MyContext < Hanami::View::Context
      #     # Injected dependency
      #     attr_reader :assets
      #
      #     def initialize(assets:, **options)
      #       @assets = assets
      #       super
      #     end
      #   end
      #
      # @api public
      def initialize(rendering: nil, **options)
        @_rendering = rendering
        @_options = options
      end

      # @api private
      def for_rendering(rendering)
        return self if rendering == _rendering

        self.class.new(**_options.merge(rendering: rendering))
      end
    end
  end
end
