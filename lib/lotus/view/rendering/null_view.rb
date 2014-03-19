module Lotus
  module View
    module Rendering
      # Null Object pattern for View.
      # It's used when the registry cannot find the a view for the given
      # context.
      #
      # @api private
      # @since 0.1.0
      class NullView
        # Initialize a view
        #
        # @param template [Lotus::View::Template] the template to render
        # @param locals [Hash] a set of objects available during the rendering
        #   process.
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Rendering#initialize
        def initialize(template, locals)
        end

        # Simulate a view rendering
        #
        # @return [nil]
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::View::Rendering#render
        def render
        end
      end
    end
  end
end
