# frozen_string_literal: true

require "dry/effects"
require "dry/equalizer"
require_relative "application_context"
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
      include Dry::Equalizer(:_options)
      include Dry::Effects.Reader(:render_env)
      include DecoratedAttributes

      attr_reader :_render_env, :_options

      def self.inherited(subclass)
        super

        # When inheriting within an Hanami app, add application context behavior
        if application_provider(subclass)
          subclass.include ApplicationContext
        end
      end

      def self.application_provider(subclass)
        if Hanami.respond_to?(:application?) && Hanami.application?
          Hanami.application.component_provider(subclass)
        end
      end
      private_class_method :application_provider

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
      def initialize(**options)
        @_options = options
      end

      # Returns a copy of the Context with new options merged in.
      #
      # This may be useful to supply values for dependencies that are _optional_
      # when initializing your custom Context subclass.
      #
      # @example
      #   class MyContext < Hanami::View::Context
      #     # Injected dependencies (request is optional)
      #     attr_reader :assets, :request
      #
      #     def initialize(assets:, request: nil, **options)
      #       @assets = assets
      #       @request = reuqest
      #       super
      #     end
      #   end
      #
      #   my_context = MyContext.new(assets: assets)
      #   my_context_with_request = my_context.with(request: request)
      #
      # @api public
      def with(**new_options)
        self.class.new(
          **_options.merge(new_options)
        )
      end
    end
  end
end
