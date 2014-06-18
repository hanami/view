module Lotus
  module View
    # Inheriting mechanisms
    #
    # @since 0.1.0
    module Inheritable
      # Register a view subclass
      #
      # @api private
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/view'
      #
      #   class IndexView
      #     include Lotus::View
      #   end
      #
      #   class JsonIndexView < IndexView
      #   end
      def inherited(base)
        subclasses.add base
      end

      # Set of registered subclasses
      #
      # @api private
      # @since 0.1.0
      def subclasses
        @@subclasses ||= Set.new
      end

      protected
      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View.load!
      def load!
        subclasses.freeze
        views.freeze
      end

      # Registered views
      #
      # @api private
      # @since 0.1.0
      def views
        @@views ||= [ self ] + subclasses.to_a
      end
    end
  end
end
